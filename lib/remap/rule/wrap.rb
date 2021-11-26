# frozen_string_literal: true

require "active_support/core_ext/array/wrap"

module Remap
  class Rule
    class Wrap < self
      using State::Extension

      attribute :type, Value(:array)
      attribute :rule, Types::Any

      # Wraps the output from {#rule} in a {#type}
      #
      # @param state [State]
      #
      # @example mapps { car: "Volvo" } to { cars: ["Volvo"] }
      #   to :cars do
      #     wrap(:array) do
      #       map :car
      #     end
      #   end
      #
      # @return [State]
      def call(state)
        rule.call(state).fmap { Array.wrap(_1) }
      end
    end
  end
end
