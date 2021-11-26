# frozen_string_literal: true

module Remap
  class Constructor
    class Argument < Concrete
      using State::Extension

      attribute :strategy, Value(:argument), default: :argument

      # Uses the {#method} method to initialize {#target} with {state}
      # Target is only called if {state} is defined
      #
      # Fails if {#target} does not respond to {#method}
      # Fails if {#target} cannot be called with {state}
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        super.fmap do |input|
          target.public_send(id, input)
        rescue ArgumentError => e
          raise e.exception("Could not load target [#{target}] using the argument strategy with [#{input}] (#{input.class})")
        end
      end
    end
  end
end
