# frozen_string_literal: true

require "active_support/configurable"

module Remap
  class Base < Mapper
    include ActiveSupport::Configurable
    include Dry::Core::Constants
    extend Dry::Monads[:result]
    using State::Extension
    extend Operation

    CONTRACT = Dry::Schema.JSON do
      # NOP
    end

    config_accessor :constructor, instance_accessor: true do
      IDENTITY
    end

    config_accessor :options, instance_accessor: true do
      EMPTY_HASH
    end

    config_accessor :rules, instance_accessor: true do
      EMPTY_ARRAY
    end

    config_accessor :contract, instance_accessor: true do
      CONTRACT
    end

    config_accessor :context, instance_accessor: true do
      IDENTITY
    end

    config_accessor :options, instance_accessor: true do
      EMPTY_ARRAY
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
    #   Mapper.call(age: '10').success? # => false
    #   Mapper.call(age: 50).success? # => true
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
    #   class Mapper < Remap
    #     define do
    #       map :a, to: :b
    #     end
    #   end
    #
    #   Mapper.call(a: 1).result # => { b: 1 }
    #
    # @example A mapper with an output constructor
    #   class Person < Dry::Struct
    #     attribute :first_name, Types::String
    #   end
    #
    #   class Mapper < Remap
    #     define(Person) do
    #       map :name, to: :first_name
    #     end
    #   end
    #
    #   Mapper.call(name: "John").result # => Person<first_name="John">
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
        contract: contract,
        attributes: attributes,
        options: options,
        rules: rules
      )
    end
  end
end
