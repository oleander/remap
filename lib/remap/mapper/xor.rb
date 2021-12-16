# frozen_string_literal: true

module Remap
  class Mapper
    using State::Extension

    # Represents two mappers that are combined with the ^ operator
    #
    # @example Combine two mappers
    #   class Mapper1 < Remap::Base
    #     contract do
    #       required(:a1)
    #     end
    #   end
    #
    #   class Mapper2 < Remap::Base
    #     contract do
    #       required(:a2)
    #     end
    #   end
    #
    #   state = Remap::State.call({ a2: 2 })
    #   output = (Mapper1 ^ Mapper2).call!(state)
    #   output.fetch(:value) # => { a2: 2 }
    class Xor < Binary
      # Succeeds if left or right succeeds, but not both
      #
      # @param state [State]
      #
      # @yieldparam [Failure] if mapper fails
      # @yieldreturn [Failure]
      #
      # @return [Result]
      def call!(state, &error)
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

      # @return [String]
      def inspect
        "%s ^ %s" % [left, right]
      end
      alias to_s inspect
    end
  end
end
