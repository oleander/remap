# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects all elements from a state
    #
    # @example Select all keys from array hash
    #   state = Remap::State.call([{a: "A1"}, {a: "A2"}])
    #   all = Remap::Selector::All.new
    #   result = all.call(state) do |other_state|
    #     value = other_state.fetch(:value).class
    #     other_state.merge(value: value)
    #   end
    #   result.fetch(:value) # => [Hash, Hash]
    class All < Concrete
      requirement Types::Enumerable

      # Iterates over state and passes each value to block
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
