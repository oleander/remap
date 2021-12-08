# frozen_string_literal: true

module Remap
  class Iteration
    using State::Extension

    # Implements a hash iterator which defines key in state
    class Hash < Concrete
      # @return [Hash]
      attribute :value, Types::Hash, alias: :hash

      # @return [State<Hash>]
      attribute :state, Types::State

      # @see Iteration#map
      def call(&block)
        hash.reduce(init) do |state, (key, value)|
          reduce(state, key, value, &block)
        end
      end

      private

      def reduce(state, key, value, &block)
        notice = catch :ignore do
          other = block[value, key: key]
          return state.combine(other.fmap { { key => _1 } })
        end

        state.set(notice: notice)
      end

      def init
        state.set(EMPTY_HASH)
      end
    end
  end
end
