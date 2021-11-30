# frozen_string_literal: true

module Remap
  class Rule
    class Collection
      using State::Extension

      # Represents an empty rule block
      #
      # @example Map any value to undefined
      #   class Mapper < Remap::Base
      #     define do
      #       map do
      #         # NOP
      #       end
      #     end
      #   end
      #
      #   Mapper.call("A").success? # => false
      class Empty < Unit
        attribute? :rules, Value(EMPTY_ARRAY), default: EMPTY_ARRAY

        # Represents an empty define block, without any rules
        #
        # @param state [State<T>]
        #
        # @return [State<T>]
        def call(state)
          state.problem("No rules, empty block")
        end
      end
    end
  end
end
