# frozen_string_literal: true

module Remap
  class Path
    # Returns the value at a given path
    #
    # @example Select "A" from { a: { b: { c: ["A"] } } }
    #   state = Remap::State.call({ a: { b: { c: ["A"] } } })
    #   first = Remap::Selector::Index.new(index: 0)
    #   result = Remap::Path::Input.new([:a, :b, :c, first]).call(state)
    #
    #   result.fetch(:value) # => "A"
    class Input < Unit
      # @return [Array<Selector>]
      attribute :segments, [Selector]

      # Selects the value at the path {#segments}
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        segments.reverse.reduce(IDENTITY) do |fn, selector|
          -> st { selector.call(st, &fn) }
        end.call(state)
      end
    end
  end
end
