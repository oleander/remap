# frozen_string_literal: true

module Remap
  class Path
    class Input < Unit
      attribute :segments, Types.Array(Selector)

      # @return [State]
      def call(state)
        segments.reverse.reduce(IDENTITY) do |fn, selector|
          -> st { selector.call(st, &fn) }
        end.call(state)
      end
    end
  end
end
