# frozen_string_literal: true

module Remap
  module State
    module Extensions
      using Object

      module Enumerable
        refine ::Enumerable do
          # Creates a hash using {self} as the {path} and {value} as the hash value
          #
          # @param value [Any] Hash value
          #
          # @example A hash from path
          #   [:a, :b].hide('value') # => { a: { b: 'value' } }
          #
          # @return [Hash]
          def hide(value)
            reverse.reduce(value) do |element, key|
              { key => element }
            end
          end

          # Fetches value at {path}
          #
          # @example Fetch value at path
          #   [[:a, :b], [:c, :d]].get(0, 1) # => :b
          #
          # @return [Any]
          #
          # @raise When path cannot be found
          def get(*path, &error)
            _, result = path.reduce([EMPTY_ARRAY, self]) do |(current_path, element), key|
              value = element.fetch(key) do
                raise PathError, current_path + [key]
              end

              [current_path + [key], value]
            end

            result
          end
        end
      end
    end
  end
end
