# frozen_string_literal: true

module Remap
  class Mapper
    using State::Extension

    # Represents two mappers that are combined with the ^ operator
    #
    # @example Combine two mappers
    #   Mapper1 ^ Mapper2
    class Xor < Binary
      # Succeedes if left or right succeeds, but not both
      #
      # @param state [State]
      #
      # @yieldparam [Failure] if mapper fails
      # @yieldreturn [Failure]
      #
      # @return [Result]
      def call!(state, &error)
        unless error
          return call!(state, &exception)
        end

        state1 = left.call!(state) do |failure1|
          return right.call!(state) do |failure2|
            return error[failure1.merge(failure2)]
          end
        end

        state2 = right.call!(state) do
          return state1
        end

        state1.combine(state2).failure("Both left and right passed xor operation").then(&error)
      end
    end
  end
end
