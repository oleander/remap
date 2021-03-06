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
        def get(*path, trace: [], &fallback)
          return self if path.empty?

          key = path.first

          unless fallback
            return get(*path, trace: trace) do
              throw :ignore, trace + [key]
            end
          end

          fetch(key, &fallback).get(*path[1..], trace: trace + [key], &fallback)
        end
      end
    end
  end
end
