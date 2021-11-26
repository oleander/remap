# frozen_string_literal: true

module Remap
  class Rule
    class Enum
      include Dry::Core::Constants
      include Dry::Monads[:maybe]

      extend Dry::Initializer

      option :mappings, default: -> { Hash.new { default } }
      option :default, default: -> { None() }

      alias execute instance_eval

      def self.call(&block)
        unless block
          raise ArgumentError, "no block given"
        end

        new.tap { _1.execute(&block) }
      end

      def [](key)
        mappings[key]
      end

      def get(key, &error)
        unless error
          return get(key) { raise Error, _1 }
        end

        mappings[key].bind { return _1 }.or do
          error["Enum key [#{key}] not found among [#{mappings.keys.inspect}]"]
        end
      end
      alias call get

      # Map all keys in {keys} to {to}
      #
      # @return [VOID]
      def from(*keys, to:)
        keys.each do |key|
          mappings[key] = Some(to)
        end
      end

      # Maps {var} to {var}
      #
      # @return [VOID]
      def value(id)
        from(id, to: id)
      end

      # Fallback value when {#call} fails
      #
      # @return [Void]
      def otherwise(value)
        mappings.default = Some(value)
      end
    end
  end
end
