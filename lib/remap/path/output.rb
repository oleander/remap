# frozen_string_literal: true

module Remap
  class Path
    using State::Extensions::Enumerable
    using State::Extension

    # Sets the value to a given path
    #
    # @example Maps "A" to { a: { b: { c: "A" } } }
    #   state = State.call("A")
    #   result = Output.new([:a, :b, :c]).call(state)
    #   result # => { a: { b: { c: "A" } } }
    class Output < Unit
      attribute :segments, [Types::Key]

      # @return [State]
      def call(state)
        state.fmap do |value|
          segments.hide(value)
        end
      end
    end
  end
end
