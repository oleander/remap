# frozen_string_literal: true

module Remap
  class Base < Mapper
    include Dry::Core::Constants
    extend Dry::Monads[:result]
    extend Dry::Configurable

    using State::Extension

    CONTRACT = Dry::Schema.JSON do
      # NOP
    end

    setting :constructor, default: IDENTITY
    setting :options, default: EMPTY_ARRAY
    setting :rules, default: EMPTY_ARRAY
    setting :contract, default: CONTRACT
    setting :context, default: IDENTITY

    schema schema.strict(false)

    # Holds the current context
    # @private
    def self.contract(&context)
      config.contract = Dry::Schema.JSON(&context)
    end

    # @see Dry::Validation::Contract.rule
    def self.rule(...)
      config.rules << ->(*) { rule(...) }
    end

    # Defines a a constructor argument for the mapper
    #
    # @param name [Symbol]
    # @param type [#call]
    def self.option(field, type: Types::Any)
      attribute(field, type)

      unless (key = schema.keys.find { _1.name == field })
        raise ArgumentError, "Could not locate [#{field}] in [#{self}]"
      end

      config.options << ->(*) { option(field, type: key) }
    end

    # Pretty print the mapper
    #
    # @return [String]
    def self.inspect
      "<#{self.class} #{rule}, #{self}>"
    end

    # Defines a mapper with a constructor used to wrap the output
    #
    # @param constructor [#call]
    #
    # @example A mapper from path :a to path :b
    #   class Mapper < Remap
    #     define do
    #       map :a, to: :b
    #     end
    #   end
    #
    #   Mapper.call(a: 1) # => { b: 1 }
    def self.define(target = Nothing, method: :new, strategy: :argument, &context)
      unless context
        raise ArgumentError, "Missing block"
      end

      config.context = Compiler.call(&context)
      config.constructor = Constructor.call(method: method, strategy: strategy, target: target)
    rescue Dry::Struct::Error => e
      raise ArgumentError, e.message
    end

    # Creates a new mapper
    #
    # @param input [Any]
    # @param params [Hash]

    # @return [Context]

    extend Operation

    def self.call!(state, &error)
      new(state.options).call(state._.set(mapper: self), &error)
    rescue Dry::Struct::Error => e
      raise ArgumentError, "Option missing to mapper [#{self}]: #{e}"
    end

    # Creates a mapper tree using {#context} and uses {#state} as argument
    #
    # @return [State]
    #
    # @see .call!
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

    def contract(scope: self)
      Class.new(Dry::Validation::Contract) do |klass|
        config = scope.class.config

        config.rules.each do |rule|
          klass.class_eval(&rule)
        end

        config.options.each do |option|
          klass.class_eval(&option)
        end

        schema(config.contract)
      end.new(**attributes)
    end

    def config
      self.class.config
    end
  end
end
