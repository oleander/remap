# frozen_string_literal: true

module Remap
  class Iteration
    class Array < Concrete
      using State::Extension

      attribute :value, Types::Array
      attribute :state, Types::State

      def map(&block)
        value.each_with_index.reduce(init) do |input_state, (value, index)|
          block[value, index: index]._.then do |new_state|
            new_state.fmap { [_1] }
          end.then do |new_array_state|
            input_state.merged(new_array_state)
          end
        end._
      end
      alias call map

      private

      def init
        state.set(EMPTY_ARRAY)
      end
    end
  end
end
