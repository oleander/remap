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
          raise ArgumentError, "All selector requires an iteration block"
        end

        value = state.fetch(:value) do
          return state
        end

        unless value.is_a?(Enumerable)
          state.fatal!("Not an enumerator")
        end

        state.map(&block)
      end
    end
  end
end
