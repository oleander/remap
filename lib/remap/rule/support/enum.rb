# frozen_string_literal: true

require "active_support/proxy_object"

module Remap
  class Rule
    class Enum < ActiveSupport::ProxyObject
      def self.const_missing(name)
        ::Object.const_get(name)
      end

      include Dry::Core::Constants
      include Dry::Monads[:maybe]

      extend Dry::Initializer

      option :mappings, default: -> { Hash.new { default } }
      option :default, default: -> { None() }

      alias execute instance_eval

      # Builds an enum using the block context
      #
      # @example
      #   enum = Enum.call do
      #     from "B", to: "C"
      #     value "A"
      #     otherwise "D"
      #   end
      #
      #   enum.get("A") # => "A"
      #   enum.get("B") # => "C"
      #   enum.get("C") # => "C"
      #   enum.get("MISSING") # => "D"
      #
      # @return [Any]
      def self.call(&block)
        unless block
          raise ArgumentError, "no block given"
        end

        enum = new
        enum.execute(&block)
        enum
      end

      # Translate {key} into a value using pre-defined mappings
      #
      # @param key [#hash]
      #
      # @yield [String]
      #   If the {key} is not found & no default value is set
      #
      # @return [Any]
      def get(key, &error)
        unless error
          return get(key) { raise Error, _1 }
        end

        self[key].bind { return _1 }.or do
          error["Enum key [#{key}] not found among [#{mappings.keys.inspect}]"]
        end
      end
      alias call get

      # @param key [Key]
      #
      # @return [Maybe]
      def [](key)
        mappings[key]
      end

      # Map all keys in {keys} to {to}
      #
      # @return [VOID]
      def from(*keys, to:)
        value = Some(to)

        keys.each do |key|
          mappings[key] = value
          mappings[to] = value
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
