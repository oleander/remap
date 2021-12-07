# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Strict < Concrete
        attribute :backtrace, Types::Backtrace

        # Represents a required mapping rule
        # When it fails, the entire mapping is marked as failed
        #
        # @param state [State]
        #
        # @return [State]
        def call(state)
          fatal(state, id: :ignore) do
            return fatal(state) do
              return notice(state) do
                return super
              end
            end
          end
        end
      end
    end
  end
end
