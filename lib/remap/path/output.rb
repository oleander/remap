module Remap
  class Path
    class Output < Value
      attribute :selectors, Types.Array(Selector)

      # @return [State]
      def call(state)
        selectors.reverse.reduce(IDENTITY) do |fn, selector|
          ->(st) { selector.call(st, &fn) }
        end.call(state)
      end
    end
  end
end
