# frozen_string_literal: true

module Remap
  class Static
    class Fixed < Concrete
      using State::Extension

      attribute :value, Types::Any

      # Set {state#value} to {#value}
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state.set(value)
      end
    end
  end
end
