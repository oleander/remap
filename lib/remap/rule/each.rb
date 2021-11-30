# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Iterates over a rule, even if the rule is not a collection
    #
    # @example Map { people: [{ name: "John" }] } to { names: ["John"] }
    #   class Mapper < Remap::Base
    #     define do
    #       map :people, to: :names do
    #         each do
    #           map :name
    #         end
    #       end
    #     end
    #   end
    #
    #   Mapper.call({ people: [{ name: "John" }] }).result # => { names: ["John"] }
    #
    # @example Upcase each value in an array
    #   state = Remap::State.call(["John", "Jane"])
    #   map = Remap::Rule::Map.new({
    #     rule: void,
    #     path: {
    #       input: [],
    #       output: []
    #     }
    #   }).then { value.upcase }
    #   each = Remap::Rule::Each.new(map)
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
