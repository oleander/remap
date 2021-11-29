# frozen_string_literal: true

module Remap
  class Selector
    class Index < Unit
      using State::Extension

      attribute :index, Integer

      requirement Types::Array

      # Selects the {#index}th element from {state} and passes it to {block}
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
