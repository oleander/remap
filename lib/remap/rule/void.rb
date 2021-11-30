# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Represents a mapping without block
    #
    # @example Maps "A" to "A"
    #   map
    class Void < Concrete
      # @param state [State<T>]
      #
      # @return [State<T>]
      def call(state)
        state.bind do |value, inner_state|
          inner_state.set(value)
        end
      end
    end
  end
end
