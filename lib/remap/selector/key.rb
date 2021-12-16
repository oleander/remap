# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects value at key from state
    #
    # @example Select the value at key :name from a hash
    #   state = Remap::State.call({ name: "John" })
    #   selector = Remap::Selector::Key.new(:name)
    #
    #   selector.call(state) do |state|
    #     state.fetch(:value)
    #   end
    class Key < Unit
      # @return [#hash
      attribute :key, Types::Key

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
          raise ArgumentError, "The key selector requires an iteration block"
        end

        hash = state.fetch(:value) { return state }

        unless hash.is_a?(Hash)
          state.fatal!("Expected hash got %s", hash.class)
        end

        value = hash.fetch(key) do
          state.ignore!("Key [%s] (%s) not found", key, key.class)
        end

        state.set(value, key: key).then(&block)
      end
    end
  end
end
