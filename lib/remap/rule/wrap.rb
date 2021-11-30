# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Wraps rule in a type
    #
    # @example Maps { name: "Ford" } to { cars: ["Ford"] }
    #   to :cars do
    #     wrap(:array) do
    #       map :name
    #     end
    #   end
    class Wrap < Concrete
      attribute :type, Value(:array)
      attribute :rule, Types::Any

      # Wraps the output from {#rule} in a {#type}
      #
      # @param state [State<T>]
      #
      # @return [State<Array<T>>]
      def call(state)
        rule.call(state).fmap { Array.wrap(_1) }
      end
    end
  end
end
