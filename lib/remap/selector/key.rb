# frozen_string_literal: true

module Remap
  class Selector
    class Key < Unit
      using State::Extension

      attribute :key, Types::Hash.not
      requirement Types::Hash.constrained(min_size: 1)

      # Fetches {#input[value]} and passes it to {block}
      #
      # @param [State] state
      #
      # @yieldparam [State]
      # @yieldreturn [State<T>]

      # @return [State<T>]
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
