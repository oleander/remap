# frozen_string_literal: true

module Remap
  class Mapper
    class And < Binary
      using State::Extension

      # Succeedes if both {left} and {right} succeed
      # Returnes the combined result of {left} and {right}
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
