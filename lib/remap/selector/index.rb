# frozen_string_literal: true

module Remap
  class Selector
    class Index < Unit
      using State::Extension

      attribute :index, Integer

      requirement Types::Array

      # Fetches {#input[value]} and passes it to {block}
      #
      # @param [State] state
      #
      # @yieldparam [State]
      # @yieldreturn [State<T>]

      # @return [State<T>]
      def call(state, &block)
        unless block
          raise ArgumentError, "no block given"
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
