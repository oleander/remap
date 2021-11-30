# frozen_string_literal: true

module Remap
  class Base < Mapper
    include Dry::Core::Constants
    extend Dry::Monads[:result]
    extend Dry::Configurable
    using State::Extension
    extend Operation

    CONTRACT = Dry::Schema.JSON do
      # NOP
    end

    setting :constructor, default: IDENTITY
    setting :options, default: EMPTY_ARRAY
    setting :rules, default: EMPTY_ARRAY
    setting :contract, default: CONTRACT
    setting :context, default: IDENTITY

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
    #   Mapper.call(age: '10') # => Failure({ age: ["must be an integer"] })
    #   Mapper.call(age: 50) # => Succcess({ person: { age: 50 } })
    #
    # @see https://dry-rb.org/gems/dry-schema/1.5/
    #
    # @return [void]
    def self.contract(&context)
      config.contract = Dry::Schema.JSON(&context)
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
    #   Mapper.call(age: 10) # => Failure({ age: ["must be at least 18 years old"] })
    #   Mapper.call(age: 50) # => Succcess({ person: { age: 50 } })
    #
    # @see https://dry-rb.org/gems/dry-validation/1.6/rules/
    #
    # @return [void]
    def self.rule(...)
      config.rules << -> * { rule(...) }
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
    #   Mapper.call(input, name: "John") # => { name: "John" }
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

      config.options << -> * { option(field, type: key) }
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
    #   Mapper.call(a: 1) # => { b: 1 }
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
    #   Mapper.call(name: "John") # => Person<first_name="John">
    #
    # @return [void]
    def self.define(target = Nothing, method: :new, strategy: :argument, &context)
      unless context
        raise ArgumentError, "Missing block"
      end

      config.context = Compiler.call(&context)
      config.constructor = Constructor.call(method: method, strategy: strategy, target: target)
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
        contract.call(input, state.options).tap do |result|
          unless result.success?
            return error[state.failure(result.errors.to_h)]
          end
        end
      end

      state.then(&config.context).then(&config.constructor)
    end

    private

    # @return [Contract]
    def contract
      Contract.call(
        contract: config.contract,
        attributes: attributes,
        options: config.options,
        rules: config.rules
      )
    end

    # @return [Dry::Configurable]
    def config
      self.class.config
    end
  end
end
