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
    #   error = -> failure { raise failure.exception }
    #   each.call(state, &error).fetch(:value) # => ["JOHN", "JANE"]
    class Each < Unit
      # @return [Rule]
      attribute :rule, Types::Rule

      # Iterates over state and passes each value to rule
      # Restores element, key & index before returning state
      #
      # @param state [State<Enumerable>]
      #
      # @return [State<Enumerable>]
      def call(state, &error)
        unless error
          raise ArgumentError, "Each#call(state, &error) requires a block"
        end

        state.map do |inner_state|
          rule.call(inner_state) do |failure|
            return error[failure]
          end
        end
      end
    end
  end
end
