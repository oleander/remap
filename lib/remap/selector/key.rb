# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects value at key from state
    #
    # @example Select the value at key :name from a hash
    #   state = Remap::State.call({ name: "John" })
    #   result = Remap::Selector::Key.new(:name).call(state)
    #   result.fetch(:value) # => "John"
    class Key < Unit
      # @return [#hash
      attribute :key, Types::Key

      requirement Types::Hash

      # Selects {#key} from state and passes it to block
      #
      # @param outer_state [State<Hash<K, V>>]
      #
      # @yieldparam [State<V>]
      # @yieldreturn [State<U>]
      #
      # @return [State<U>]
      def call(outer_state, &block)
        unless block_given?
          raise ArgumentError, "The key selector requires an iteration block"
        end

        outer_state.bind(key: key) do |hash, state|
          requirement[hash] do
            state.fatal!("Expected hash but got %p (%s)", hash, hash.class)
          end

          value = hash.fetch(key) do
            state.ignore!("Key %p (%s) not found in hash %p (%s)",
                          key,
                          key.class,
                          hash,
                          hash.class)
          end

          state.set(value, key: key).then(&block)
        end
      end
    end
  end
end
