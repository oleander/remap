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
        s0 = block[value, key: key]
        s1 = s0.set(fatal_id: state.fatal_id, ids: state.ids)
        state.combine(s1.fmap { { key => _1 } })
      end

      def init
        state.set(EMPTY_HASH)
      end
    end
  end
end
