# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    class Block < Unit
      # @return [Array<Rule>]
      attribute :rules, [Types::Rule]

      # Represents a non-empty define block with one or more rules
      # Calls every {#rules} with state and merges the output
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        s0 = state.except(:value)

        if rules.empty?
          return s0
        end

        catch do |id|
          s1 = s0.set(id: id)

          rules.reduce(s1) do |s2, rule|
            s2.combine(rule.call(state))
          end.except(:id)
        end
      end
    end
  end
end
