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
        init = state.except(:value)

        if rules.empty?
          return init
        end

        catch_fatal(init, backtrace) do |s1, fatal_id:|
          s2 = state.set(fatal_id: fatal_id)

          catch_ignored(s1) do |s3, id:|
            rules.reduce(s3) do |s4, rule|
              s5 = rule.call(s2)
              s6 = s5.set(id: id)
              s4.combine(s6)
            end
          end
        end
      end
    end
  end
end
