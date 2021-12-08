# frozen_string_literal: true

module Remap
  class Iteration
    using State::Extension

    # Default iterator which doesn't do anything
    class Other < Concrete
      attribute :value, Types::Any, alias: :other
      attribute :state, Types::State

      # @see Iteration#map
      def call(&block)
        state.fatal!("Expected an enumerable, got %s (%s)", value, value.class)
      end
    end
  end
end
