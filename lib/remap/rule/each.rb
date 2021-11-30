# frozen_string_literal: true

module Remap
  class Rule
    # Iterates over a rule, even if the rule is not a collection
    #
    # @example Map { people: [{ name: "John" }] } to { names: ["John"] }
    #   map :people, to: :names do
    #     each do
    #       map :name
    #     end
    #   end
    class Each < Value
      using State::Extension

      attribute :rule, Types::Rule

      # Iterates over {state} and passes each value to {rule}
      # Restores {element}, {key} & {index} before returning state
      #
      # @param state [State<Enumerable>]
      #
      # @return [State<Enumerable>]
      def call(state)
        state.map do |inner_state|
          rule.call(inner_state)
        end
      end
    end
  end
end
