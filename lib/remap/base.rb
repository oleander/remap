# frozen_string_literal: true

require "active_support/configurable"
require "active_support/core_ext/object/with_options"

module Remap
  # @example Maps ["A", "B", "C"] to ["B"]
  #   class Mapper < Remap::Base
  #     define do
  #       each do
  #         map.if do
  #           value.include?("B")
  #         end
  #       end
  #     end
  #   end
  #
  #   Mapper.call(["A", "B", "C"]).result # => ["B"]
  # @example Maps { a: { b: "A" } } to "A"
  #   class Mapper < Remap::Base
  #     define do
  #       map(:a, :b).enum do
  #         value "A", "B"
  #       end
  #     end
  #   end
  #
  #   Mapper.call({ a: { b: "A" } }).result # => "A"
  #   Mapper.call({ a: { b: "B" } }).result # => "B"
  #
  # @example Ignore rule for input { a: { b: "A" } }
  #   class Mapper < Remap::Base
  #     define do
  #       map(:a, :b).pending
  #     end
  #   end
  #
  #   Mapper.call({ a: { b: "A" } }).problems.count # => 1
  #
  # @example Map { people: [{ name: "John" }] } to { names: ["John"] }
  #   class Mapper < Remap::Base
  #     define do
  #       map :people, to: :names do
  #         each do
  #           map :name
  #         end
  #       end
  #     end
  #   end
  #
  #   Mapper.call({ people: [{ name: "John" }] }).result # => { names: ["John"] }
  #
  # @example Map "Hello" to "Hello!"
  #   class Mapper < Remap::Base
  #     define do
  #       map.adjust do
  #         "#{value}!"
  #       end
  #     end
  #   end
  #
  #   Mapper.call("Hello").result # => "Hello!"
  #
  class Base < Mapper
    include ActiveSupport::Configurable
    include Dry::Core::Constants
    using State::Extension
    extend Operation

    with_options instance_accessor: true do |scope|
      scope.config_accessor(:contract) { Dry::Schema.JSON {} }
      scope.config_accessor(:constructor) { IDENTITY }
      scope.config_accessor(:options) { EMPTY_ARRAY }
      scope.config_accessor(:option) { EMPTY_HASH }
      scope.config_accessor(:rules) { EMPTY_ARRAY }
      scope.config_accessor(:context) { IDENTITY }
    end

    schema schema.strict(false)

    # Defines a schema for the mapper
    # If the schema fail, the mapper will fail
    #
    # @example Guard against missing values
    #   class Mapper < Remap::Base
    #     contract do
    #       required(:age).filled(:integer)
    #     end
    #
    #     define do
    #       map :age, to: [:person, :age]
    #     end
    #   end
    #
    #   Mapper.call({age: '10'}).success? # => false
    #   Mapper.call({age: 50}).success? # => true
    #
    # @see https://dry-rb.org/gems/dry-schema/1.5/
    #
    # @return [void]
    def self.contract(&context)
      self.contract = Dry::Schema.JSON(&context)
    end

    # Defines a rule for the mapper
    # If the rule fail, the mapper will fail
    #
    # @example Guard against values
    #   class Mapper < Remap::Base
    #     contract do
    #       required(:age)
    #     end
    #
    #     rule(:age) do
    #       unless value >= 18
    #         key.failure("must be at least 18 years old")
    #       end
    #     end
    #
    #     define do
    #       map :age, to: [:person, :age]
    #     end
    #   end
    #
    #   Mapper.call({age: 10}).success? # => false
    #   Mapper.call({age: 50}).success? # => true
    #
    # @see https://dry-rb.org/gems/dry-validation/1.6/rules/
    #
    # @return [void]
    def self.rule(...)
      self.rules = rules + [-> * { rule(...) }]
    end

    # Defines a required option for the mapper
    #
    # @example A mapper that takes an argument name
    #   class Mapper < Remap::Base
    #     option :name
    #
    #     define do
    #       set :name, to: option(:name)
    #     end
    #   end
    #
    #   Mapper.call({}, name: "John").result # => { name: "John" }
    #
    # @param field [Symbol]
    # @option type (Types::Any) [#call]
    #
    # @return [void]
    def self.option(field, type: Types::Any)
      attribute(field, type)

      unless (key = schema.keys.find { _1.name == field })
        raise ArgumentError, "[BUG] Could not locate [#{field}] in [#{self}]"
      end

      self.options = options + [-> * { option(field, type: key) }]
    end

    # Defines a mapper rules and possible constructor
    #
    # @param target (Nothing) [#call]
    #
    # @option method (:new) [Symbol]
    # @option strategy (:argument) [:argument, :keywords, :none]
    #
    # @example A mapper, which mapps a value at [:a] to [:b]
    #   class Mapper < Remap::Base
    #     define do
    #       map :a, to: :b
    #     end
    #   end
    #
    #   Mapper.call({a: 1}).result # => { b: 1 }
    #
    # @example A mapper with an output constructor
    #   class Person < Dry::Struct
    #     attribute :first_name, Dry::Types['strict.string']
    #   end
    #
    #   class Mapper < Remap::Base
    #     define(Person) do
    #       map :name, to: :first_name
    #     end
    #   end
    #
    #   Mapper.call({name: "John"}).result.first_name # => "John"
    #
    # @return [void]
    def self.define(target = Nothing, method: :new, strategy: :argument, &context)
      unless context
        raise ArgumentError, "Missing block"
      end

      self.context = Compiler.call(&context)
      self.constructor = Constructor.call(method: method, strategy: strategy, target: target)
    rescue Dry::Struct::Error => e
      raise ArgumentError, e.message
    end

    # Similar to {::call}, but takes a state
    #
    # @param state [State]
    #
    # @yield [Failure] if mapper fails
    #
    # @return [Result] if mapper succeeds
    #
    # @private
    def self.call!(state, &error)
      new(state.options).call(state._.set(mapper: self), &error)
    rescue Dry::Struct::Error => e
      raise ArgumentError, "Option missing to mapper [#{self}]: #{e}"
    end

    # Mappers state according to the mapper rules
    #
    # @param state [State]
    #
    # @yield [Failure] if mapper fails
    #
    # @return [State]
    #
    # @private
    def call(state, &error)
      unless error
        raise ArgumentError, "Missing block"
      end

      state.tap do |input|
        validation.call(input, state.options).tap do |result|
          unless result.success?
            return error[state.failure(result.errors.to_h)]
          end
        end
      end

      state.then(&context).then(&constructor)
    end

    private

    # @return [Contract]
    def validation
      Contract.call(
        attributes: attributes,
        contract: contract,
        options: options,
        rules: rules
      )
    end
  end
end
