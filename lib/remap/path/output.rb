# frozen_string_literal: true

module Remap
  class Path
    using Extensions::Enumerable
    using State::Extension

    # TODO: Move & Test
    module Dispatch
      refine Static::Option do
        def call(...)
          super.value
        end
      end

      refine Object do
        def call(_)
          self
        end
      end
    end

    # Sets the value to a given path
    #
    # @example Maps "A" to { a: { b: { c: "A" } } }
    #   state = Remap::State.call("A")
    #   result = Remap::Path::Output.new([:a, :b, :c]).call(state)
    #
    #   result.fetch(:value) # => { a: { b: { c: "A" } } }
    class Output < Unit
      using Dispatch

      attribute :selectors, [Types::Key]

      # @return [State]
      def call(state)
        mapped = selectors.map do |selector|
          selector.call(state)
        end

        state.fmap do |value|
          mapped.hide(value)
        end
      end
    end
  end
end
