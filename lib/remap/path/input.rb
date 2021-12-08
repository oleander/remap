# frozen_string_literal: true

module Remap
  class Path
    using State::Extension

    # Returns the value at a given path
    #
    # @example Select "A" from { a: { b: { c: ["A"] } } }
    #   state = Remap::State.call({ a: { b: { c: ["A"] } } })
    #   first = Remap::Selector::Index.new(index: 0)
    #   path = Remap::Path::Input.new([:a, :b, :c, first])
    #
    #   path.call(state) do |state|
    #     state.fetch(:value)
    #   end
    class Input < Unit
      # @return [Array<Selector>]
      attribute :selectors, [Selector]

      # @param state [State]
      #
      # @yieldparam [State]
      # @yieldreturn [State]
      #
      # @return [State]
      def call(state, &iterator)
        unless block_given?
          raise ArgumentError, "Input path requires an iterator block"
        end

        selectors.reverse.reduce(iterator) do |inner_iterator, selector|
          -> inner_state { selector.call(inner_state, &inner_iterator) }
        end.call(state)
      end
    end
  end
end
