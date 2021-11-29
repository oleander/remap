# frozen_string_literal: true

module Remap
  class Rule
    class Void < self
      using State::Extension

      # Returns its input
      #
      # @param state [State]
      #
      # @example An empty rule
      #   class Mapper < Remap::Base
      #     define do
      #       map do
      #         # Empty ...
      #       end
      #     end
      #   end
      #
      #   Mapper.call(input) # => input
      #
      # @return [State]
      def call(state)
        state.bind do |value, inner_state|
          inner_state.set(value)
        end
      end
    end
  end
end
