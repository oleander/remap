# frozen_string_literal: true

module Remap
  class Rule
    class Collection
      using State::Extension

      # Represents an empty rule block
      class Empty < Unit
        attribute? :rules, Value(EMPTY_ARRAY), default: EMPTY_ARRAY

        # Represents an empty define block, without any rules
        #
        # @param state [State<T>]
        #
        # @return [State<T>]
        def call(state)
          state.notice!("No rules, empty block")
        end
      end
    end
  end
end
