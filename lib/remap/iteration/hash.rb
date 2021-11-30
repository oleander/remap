# frozen_string_literal: true

module Remap
  class Iteration
    using State::Extension

    class Hash < Concrete
      attribute :value, Types::Hash, alias: :hash
      attribute :state, Types::State

      # @see Base#map
      def call(&block)
        hash.reduce(init) do |input_state, (key, value)|
          block[value, key: key]._.then do |new_state|
            new_state.fmap { { key => _1 } }
          end.then do |new_hash_state|
            input_state.combine(new_hash_state)
          end
        end._
      end

      private

      def init
        state.set(EMPTY_HASH)
      end
    end
  end
end
