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

      # @see Iteration#map
      def call(&block)
        array.each_with_index.reduce(init) do |state, (value, index)|
          reduce(state, value, index, &block)
        end
      end

      private

      def init
        state.set(EMPTY_ARRAY)
      end

      def reduce(state, value, index, &block)
        s0 = block[value, index: index]
        s1 = s0.set(**state.only(:ids, :fatal_id))
        state.combine(s1.fmap { [_1] })
      end
    end
  end
end
