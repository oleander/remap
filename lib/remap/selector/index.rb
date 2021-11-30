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
      # @param state [State<Array<T>>]
      #
      # @yieldparam [State<T>]
      # @yieldreturn [State<U>]
      #
      # @return [State<U>]
      def call(state, &block)
        unless block
          return call(state, &:itself)
        end

        state.bind(index: index) do |array, inner_state, &error|
          requirement[array] do
            return error["Expected an array"]
          end

          element = array.fetch(index) do
            return error["No element on index at index #{index}"]
          end

          block[inner_state.set(element, index: index)]
        end
      end
    end
  end
end
