# frozen_string_literal: true

module Remap
  class Rule
    class Map
      class Enum < Proxy
        # @return [Hash]
        option :table, default: -> { {} }
        option :default, default: -> { Undefined }

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

        # Translates key into a value using predefined table
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

          table.fetch(key) do
            unless default == Undefined
              return default
            end

            error["Enum key [#{key}] not found among [#{table.keys.inspect}]"]
          end
        end
        alias call get

        # @return [void]
        def from(*keys, to:)
          keys.each do |key|
            table[key] = to
            table[to] = to
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
          @default = value
        end
      end
    end
  end
end
