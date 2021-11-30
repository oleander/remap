# frozen_string_literal: true

module Remap
  class Rule
    class Path < Dry::Value
      attribute :selectors, Types.Array(Selector)

      def call(state)
        selectors.reverse.reduce(IDENTITY) do |fn, selector|
          ->(st) { selector.call(st, &fn) }
        end.call(state)
      end
    end
  end
end
