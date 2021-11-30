# frozen_string_literal: true

module Remap
  class Mapper
    using State::Extension

    # Represents two mappers that are combined with the & operator
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
    #   state = Remap::State.call({ a2: 2, a1: 1 })
    #   output = (Mapper1 & Mapper2).call(state)
    #   output.result # => { a2: 2, a1: 1 }
    class And < Binary
      # Succeeds if both left and right succeed
      # Returns the combined result of left and right
      #
      # @param state [State]
      #
      # @yield [Failure] if mapper fails
      #
      # @return [Result]
      def call!(state, &error)
        unless error
          return call!(state, &exception)
        end

        state1 = left.call!(state) do |failure1|
          right.call!(state) do |failure2|
            return error[failure1.merge(failure2)]
          end

          return error[failure1]
        end

        state2 = right.call!(state) do |failure|
          return error[failure]
        end

        state1.combine(state2)
      end
    end
  end
end
