# frozen_string_literal: true

module Remap
  class Rule
    class Path < Dry::Concrete
      using State::Extension
      using State::Extensions::Enumerable

      # @example [:a, :b, :c]
      attribute :to, Types.Array(Types::Key), alias: :output_path

      # @example [:a, 0, :b, ALL]
      attribute :map, Types.Array(Selector), alias: :input_path

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
          output_path.hide(value)
        end
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
