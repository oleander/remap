# frozen_string_literal: true

require "active_support/configurable"
require "active_support/core_ext/object/with_options"

module Remap
  # @example Select all elements
  #   class Mapper < Remap::Base
  #     define do
  #       map [all, :name]
  #     end
  #   end
  #
  #   Mapper.call([{ name: "John" }, { name: "Jane" }]) # => ["John", "Jane"]
  #
  # @example Given an option
  #   class Mapper < Remap::Base
  #     option :name
  #
  #     define do
  #       set [:person, :name], to: option(:name)
  #     end
  #   end
  #
  #   Mapper.call({}, name: "John") # => { person: { name: "John" } }
  #
  # @example Given a value
  #   class Mapper < Remap::Base
  #     define do
  #       set [:api_key], to: value("ABC-123")
  #     end
  #   end
  #
  #   Mapper.call({}) # => { api_key: "ABC-123" }
  #
  # @example Maps ["A", "B", "C"] to ["A", "C"]
  #   class Mapper < Remap::Base
  #     define do
  #       each do
  #         map.if_not do
  #           value.include?("B")
  #         end
  #       end
  #     end
  #   end
  #
  #   Mapper.call(["A", "B", "C"]) # => ["A", "C"]
  #
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
  #   Mapper.call(["A", "B", "C"]) # => ["B"]
  #
  # @example Maps { a: { b: "A" } } to "A"
  #   class Mapper < Remap::Base
  #     define do
  #       map(:a, :b).enum do
  #         value "A", "B"
  #       end
  #     end
  #   end
  #
  #   Mapper.call({ a: { b: "A" } }) # => "A"
  #   Mapper.call({ a: { b: "B" } }) # => "B"
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
  #   Mapper.call({ people: [{ name: "John" }] }) # => { names: ["John"] }
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
  #   Mapper.call("Hello") # => "Hello!"
  #
  # @example Select the second element from an array
  #   class Mapper < Remap::Base
  #     define do
  #       map [at(1)]
  #     end
  #   end
  #
  #   Mapper.call([1, 2, 3]) # => 2
  class Base < Mapper
    include ActiveSupport::Configurable
    include Dry::Core::Constants
    using State::Extension
    extend Operation

    with_options instance_accessor: true do |scope|
      scope.config_accessor(:contract) { Dry::Schema.define {} }
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
    #   class MapperWithAge < Remap::Base
    #     contract do
    #       required(:age).filled(:integer)
    #     end
    #
    #     define do
    #       map :age, to: [:person, :age]
    #     end
    #   end
    #
    #   MapperWithAge.call({age: 50}) # => { person: { age: 50 } }
    #   MapperWithAge.call({age: '10'}) do |failure|
    #     # ...
    #   end
    #
    # @see https://dry-rb.org/gems/dry-schema/1.5/
    #
    # @return [void]
    def self.contract(&context)
      self.contract = Dry::Schema.define(&context)
    end

    # Defines a rule for the mapper
    # If the rule fail, the mapper will fail
    #
    # @example Guard against values
    #   class MapperWithRule < Remap::Base
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
    #   MapperWithRule.call({age: 50}) # => { person: { age: 50 } }
    #   MapperWithRule.call({age: 10}) do |failure|
    #     # ...
    #   end
    #
    # @see https://dry-rb.org/gems/dry-validation/1.6/rules/
    #
    # @return [void]
    def self.rule(...)
      self.rules = rules + [-> { rule(...) }]
    end

    # Defines a required option for the mapper
    #
    # @example A mapper that takes an argument name
    #   class MapperWithOption < Remap::Base
    #     option :name
    #
    #     define do
    #       set :name, to: option(:name)
    #     end
    #   end
    #
    #   MapperWithOption.call({}, name: "John") # => { name: "John" }
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
    # @example A mapper, which maps a value at [:a] to [:b]
    #   class Mapper < Remap::Base
    #     define do
    #       map :a, to: :b
    #     end
    #   end
    #
    #   Mapper.call({a: 1}) # => { b: 1 }
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
    #   Mapper.call({name: "John"}).first_name # => "John"
    #
    # @return [void]
    def self.define(target = Nothing, method: :new, strategy: :argument, &context)
      unless block_given?
        raise ArgumentError, "#{self}.define requires a block"
      end

      self.constructor = Constructor.call(method: method, strategy: strategy, target: target)
      self.context = Compiler.call(&context)
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
      unless block_given?
        raise ArgumentError, "Base#call(state, &error) requires block"
      end

      state.tap do |input|
        validation.call(input, state.options).tap do |result|
          unless result.success?
            return error[state.failure(result.errors.to_h)]
          end
        end
      end

      notice = catch :fatal do
        return context.call(state) do |failure|
          return error[failure]
        end.then(&constructor)
      end

      error[state.failure(notice)]
    end

    private

    # @return [Contract]
    def validation
      Contract.call(attributes: attributes, contract: contract, options: options, rules: rules)
    end
  end
end
