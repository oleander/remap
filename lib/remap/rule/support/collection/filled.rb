# frozen_string_literal: true

module Remap
  class Rule
    class Collection
      class Filled < Unit
        using State::Extension

        attribute :rules, [Types.Interface(:call)], min_size: 1

        # Represents a non-empty define block with one or more rules
        # Calls every {#rules} with {input} and merges the output
        #
        # @param state [State]
        #
        # @return [State]
        def call(state)
          rules.map do |rule|
            Thread.new(rule, state) { _1.call(_2) }
          end.map(&:value).reduce do |acc, inner_state|
            acc.merged(inner_state)
          end
        end
      end
    end
  end
end
