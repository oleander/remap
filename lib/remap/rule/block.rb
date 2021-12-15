# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    class Block < Unit
      # @return [Array<Rule>]
      attribute :backtrace, [String], min_size: 1
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

        failure = catch_fatal do |fatal_id|
          s1 = s0.set(fatal_id: fatal_id)
          s4 = state.set(fatal_id: fatal_id)

          return catch_ignored do |id|
            s2 = s1.set(id: id)

            rules.reduce(s2) do |s3, rule|
              s5 = s3
              s6 = rule.call(s4)
              s7 = s6.set(id: id)
              s5.combine(s7)
            end
          end.remove_id.remove_fatal_id
        end

        raise failure.exception(backtrace)
      end
    end
  end
end
