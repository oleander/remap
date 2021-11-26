# frozen_string_literal: true

module Remap
  class Rule
    class Path < Struct
      using State::Extension

      # @example [:a, :b, :c]
      attribute :to, Types.Array(Types::Key)

      # @example [:a, 0, :b, ALL]
      attribute :map, Types.Array(Selector)

      # Maps {state} from {map} to {block} to {to}
      #
      # @param state [State]
      #
      # @yieldparam [State]
      # @yieldreturn [State<T>]
      #
      # @return [State<T>]
      def call(state, &block)
        unless block
          raise ArgumentError, "block required"
        end

        selector(state).then(&block).fmap do |value|
          to.reverse.reduce(value) do |val, key|
            { key => val }
          end
        end._
      end

      private

      def selector(state)
        stack = map.reverse.reduce(IDENTITY) do |fn, selector|
          ->(st) { selector.call(st, &fn) }
        end

        stack.call(state)
      end
    end
  end
end
