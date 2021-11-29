# frozen_string_literal: true

module Remap
  module State
    module Extensions
      module Array
        refine ::Array do
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

          def get(*path, last)
            if path.empty?
              return fetch(last) do
                throw :missing, path + [last]
              end
            end

            dig(*path).fetch(last) do
              throw :missing, path + [last]
            end
          end
        end
      end
    end
  end
end
