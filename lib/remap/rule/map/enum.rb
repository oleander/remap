# frozen_string_literal: true

module Remap
  class Rule
    class Map
      class Enum < Proxy
        include Dry::Monads[:maybe]

        # @return [Hash]
        option :mappings, default: -> { Hash.new { default } }

        # @return [Maybe]
        option :default, default: -> { None() }

        alias execute instance_eval

        # Builds an enumeration using the block as context
        #
        # @example
        #   enum = Remap::Rule::Map::Enum.call do
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

          new.tap { _1.execute(&block) }
        end

        # Translates key into a value using predefined mappings
        #
        # @param key [#hash]
        #
        # @yield [String]
        #   If the key is not found & no default value is set
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

        # @return [Maybe]
        def [](key)
          mappings[key]
        end

        # @return [void]
        def from(*keys, to:)
          value = Some(to)

          keys.each do |key|
            mappings[key] = value
            mappings[to] = value
          end
        end

        # @return [void]
        def value(*ids)
          ids.each do |id|
            from(id, to: id)
          end
        end

        # @return [void]
        def otherwise(value)
          mappings.default = Some(value)
        end
      end
    end
  end
end
