# frozen_string_literal: true

module Remap
  class Rule
    class Collection
      class Empty < Unit
        using State::Extension

        attribute? :rules, Value(EMPTY_ARRAY).default { EMPTY_ARRAY }

        # Represents an empty define block, without any rules
        #
        # @param input [Any]
        # @param state [State]
        #
        # @return [Monad::Failure]
        def call(state)
          state.problem("No rules, empty block")
        end
      end
    end
  end
end
