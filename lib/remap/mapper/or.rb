# frozen_string_literal: true

module Remap
  class Mapper
    using State::Extension

    # Represents two mappers that are combined with the | operator
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
    #   result = (Mapper1 | Mapper2).call!(state)
    #   result.fetch(:value) # => { a2: 2 }
    class Or < Binary
      # Succeeds if left or right succeeds
      # Returns which ever succeeds first
      #
      # @param state [State]
      #
      # @yieldparam [Failure] if mapper fails
      # @yieldreturn [Failure]
      #
      # @return [Result]
      def call!(state, &error)
        left.call!(state) do |failure1|
          return right.call!(state) do |failure2|
            return error[failure1.merge(failure2)]
          end
        end
      end
    end
  end
end
