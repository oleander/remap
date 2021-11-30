# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Iterates over a rule, even if the rule is not a collection
    #
    # @example Map { people: [{ name: "John" }] } to { names: ["John"] }
    #   map :people, to: :names do
    #     each do
    #       map :name
    #     end
    #   end
    class Each < Unit
      attribute :rule, Types::Rule

      # Iterates over {state} and passes each value to {rule}
      # Restores {element}, {key} & {index} before returning state
      #
      # @param state [State<Enumerable>]
      #
      # @return [State<Enumerable>]
      def call(state)
        state.map(&rule)
      end
    end
  end
end
