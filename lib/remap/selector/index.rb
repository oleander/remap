# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects value at given index
    #
    # @example Select the value at index 1 from a array
    #   state = Remap::State.call([:one, :two, :tree])
    #   index = Remap::Selector::Index.new(1)
    #
    #   result = index.call(state) do |element|
    #     value = element.fetch(:value)
    #     element.merge(value: value.upcase)
    #   end
    #
    #   result.fetch(:value) # => :TWO
    class Index < Unit
      # @return [Integer]
      attribute :index, Integer

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
          raise ArgumentError, "The index selector requires an iteration block"
        end

        array = state.fetch(:value) { return state }

        unless array.is_a?(Array)
          state.fatal!("Expected an array got %s", array.class)
        end

        value = array.fetch(index) do
          state.ignore!("Index [%s] (%s) not found", index, index.class)
        end

        state.set(value, index: index).then(&block)
      end
    end
  end
end
