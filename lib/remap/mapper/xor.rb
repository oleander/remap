# frozen_string_literal: true

module Remap
  class Mapper
    class Xor < Binary
      using State::Extension

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

        error[state1.merged(state2).failure("Both left and right passed in xor")]
      end
    end
  end
end
