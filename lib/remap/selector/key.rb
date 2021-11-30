# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects value at key from state
    #
    # @example Select the value at key :name from a hash
    #   map :key
    class Key < Unit
      # @return [#hash
      attribute :key, Types::Key

      requirement Types::Hash.constrained(min_size: 1)

      # Selects {#key} from state and passes it to block
      #
      # @param state [State<Hash<K, V>>]
      #
      # @yieldparam [State<V>]
      # @yieldreturn [State<U>]
      #
      # @return [State<U>]
      def call(state, &block)
        unless block
          return call(state, &:itself)
        end

        state.bind(key: key) do |hash, inner_state, &error|
          requirement[hash] do
            return error["Expected a hash"]
          end

          value = hash.fetch(key) do
            return error["Key [#{key}] not found"]
          end

          block[inner_state.set(value, key: key)]
        end
      end
    end
  end
end
