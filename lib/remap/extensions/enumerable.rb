# frozen_string_literal: true

module Remap
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
        def get(*path, trace: EMPTY_ARRAY, &fallback)
          return self if path.empty?

          key = path.first

          unless block_given?
            get(*path, trace: trace) do
              raise PathError, trace + [key]
            end
          end

          fetch(key, &fallback).get(*path[1..], trace: trace + [key], &fallback)
        rescue TypeError
          raise PathError, trace + [key]
        end
      end
    end
  end
end
