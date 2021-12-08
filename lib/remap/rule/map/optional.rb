# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Optional < Concrete
        # Represents an optional mapping rule
        # When the mapping fails, the value is ignored
        #
        # @param state [State]
        #
        # @return [State]
        def call(state, &error)
          unless error
            raise ArgumentError, "map.call(state, &error) requires a block"
          end

          fatal(state) do
            return ignore(state) do
              return notice(state) do
                return super
              end
            end
          end
        end

        private

        # Catches :ignore exceptions and re-package them as a state
        #
        # @param state [State]
        #
        # @return [State]
        def ignore(state, &block)
          state.set(notice: catch(:ignore, &block).traced(backtrace)).except(:value)
        end
      end
    end
  end
end
