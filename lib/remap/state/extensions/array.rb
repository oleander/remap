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

          def get(*path)
            if path.empty?
              throw :missing, []
            end

            _, result = path.reduce([[], self]) do |(current_path, element), key|
              value = element.fetch(key) do
                throw :missing, current_path + [key]
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
