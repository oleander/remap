# frozen_string_literal: true

module Remap
  class Path
    using Extensions::Enumerable
    using State::Extension

    # Sets the value to a given path
    #
    # @example Maps "A" to { a: { b: { c: "A" } } }
    #   state = Remap::State.call("A")
    #   result = Remap::Path::Output.new([:a, :b, :c]).call(state)
    #
    #   result.fetch(:value) # => { a: { b: { c: "A" } } }
    class Output < Unit
      attribute :selectors, [Types::Key]

      # @return [State]
      def call(state)
        state.fmap do |value|
          selectors.hide(value)
        end
      end
    end
  end
end
