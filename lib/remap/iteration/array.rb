# frozen_string_literal: true

module Remap
  class Iteration
    using State::Extension

    # Implements an array iterator which defines index in state
    class Array < Concrete
      # @return [Array<T>]
      attribute :value, Types::Array, alias: :array

      # @return [State<Array<T>>]
      attribute :state, Types::State

      # Defines an array iterator that will iterate over {#value}
      #
      # @yieldparam value [T]
      # @yieldparam index: [Integer]
      #
      # @yieldreturn [State<T>]
      #
      # @return [State<Array<T>>]
      def call(&block)
        array.each_with_index.reduce(init) do |input_state, (value, index)|
          block[value, index: index]._.then do |new_state|
            new_state.fmap { [_1] }
          end.then do |new_array_state|
            input_state.combine(new_array_state)
          end
        end
      end

      private

      def init
        state.set(EMPTY_ARRAY)
      end
    end
  end
end
