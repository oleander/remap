# frozen_string_literal: true

module Remap
  class Mapper
    # Represents two mappers that are combined with the {|} operator
    #
    # @example Combine two mappers
    #   Mapper1 | Mapper2
    class Or < Binary
      using State::Extension

      # Succeedes if {left} or {right} succeeds
      # Returns which ever succeeds first
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

        left.call!(state) do |failure1|
          return right.call!(state) do |failure2|
            return error[failure1.merge(failure2)]
          end
        end
      end
    end
  end
end
