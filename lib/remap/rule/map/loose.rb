# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Loose < Concrete
        def call(state)
          fatal(state) do
            return ignore(state) do
              return notice(state) do
                return super
              end
            end
          end
        end

        def ignore(state, &block)
          state.set(notice: catch(:ignore, &block).traced(backtrace)).except(:value)
        end
      end
    end
  end
end
