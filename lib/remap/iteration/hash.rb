# frozen_string_literal: true

module Remap
  class Iteration
    class Hash < Concrete
      attribute :value, Types::Hash
      attribute :state, Types::State

      using State::Extension

      # @see Base#map
      def map(&block)
        value.reduce(init) do |input_state, (key, value)|
          block[value, key: key]._.then do |new_state|
            new_state.fmap { { key => _1 } }
          end.then do |new_hash_state|
            input_state.merged(new_hash_state)
          end
        end._
      end
      alias call map

      private

      def init
        state.set(EMPTY_HASH)
      end
    end
  end
end
