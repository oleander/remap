# frozen_string_literal: true

module Remap
  class Constructor
    class None < Concrete
      attribute :target, Types::Nothing
      attribute :strategy, Types::Any
      attribute :method, Types::Any

      # Just returns the input state
      #
      # Fails if {#target} does not respond to {#method}
      # Fails if {#target} cannot be called with {state}
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state
      end
    end
  end
end
