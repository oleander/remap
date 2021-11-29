# frozen_string_literal: true

module Remap
  class Selector
    # Selects all elements from a state
    #
    # @example Select all elements
    #   map [:people, all, :name]
    class All < Concrete
      using State::Extension

      requirement Types::Enumerable

      # Iterates over {state} and passes each value to {block}
      #
      # @param state [State<Enumerable<T>>]
      #
      # @yieldparam [State<T>]
      # @yieldreturn [State<U>]
      #
      # @return [State<U>]
      def call(state, &block)
        unless block
          return call(state, &:itself)
        end

        state.bind(quantifier: "*") do |enumerable, inner_state, &error|
          requirement[enumerable] do
            return error["Expected an enumeration"]
          end

          inner_state.map(&block)
        end
      end
    end
  end
end
