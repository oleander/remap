# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects value at given index
    #
    # @example Select the value at index 1 from a array
    #   state = Remap::State.call([:one, :two, :tree])
    #   result = Remap::Selector::Index.new(1).call(state)
    #   result.fetch(:value) # => :two
    class Index < Unit
      # @return [Integer]
      attribute :index, Integer

      requirement Types::Array

      # Selects the {#index}th element from state and passes it to block
      #
      # @param outer_state [State<Array<T>>]
      #
      # @yieldparam [State<T>]
      # @yieldreturn [State<U>]
      #
      # @return [State<U>]
      def call(outer_state, &block)
        return call(outer_state, &:itself) unless block

        outer_state.bind(index: index) do |array, state|
          requirement[array] do
            state.fatal!("Expected array but got %p (%s)", array, array.class)
          end

          element = array.fetch(index) do
            state.ignore!("Index %s in array %p (%s) not found",
                          index,
                          array,
                          array.class)
          end

          state.set(element, index: index).then(&block)
        end
      end
    end
  end
end
