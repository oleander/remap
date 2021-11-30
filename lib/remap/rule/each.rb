# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Iterates over a rule, even if the rule is not a collection
    #

    # @example Upcase each value in an array
    #   state = Remap::State.call(["John", "Jane"])
    #   upcase = Remap::Rule::Map.call({}).then(&:upcase)
    #   each = Remap::Rule::Each.call(rule: upcase)
    #   each.call(state).fetch(:value) # => ["JOHN", "JANE"]
    class Each < Unit
      # @return [Rule]
      attribute :rule, Rule

      # Iterates over state and passes each value to rule
      # Restores element, key & index before returning state
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
