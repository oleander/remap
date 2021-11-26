# frozen_string_literal: true

module Remap
  class Rule
    class Map < self
      using State::Extension

      attribute :rule, Types.Interface(:call)
      attribute :path, Path

      # Maps {input} in 4 steps
      #
      # 1. Extract value from {input} using {path}
      # 2. For each yielded value
      #   2.1. Map value using {#rule}
      #   2.2. Map value using {#fn}

      # @example Map :a, to :b and add 5
      #  map = Map.new({
      #    path: { map: :a, to: :b },
      #    rule: Void.new,
      #  })
      #
      #  map.adjust do |value|
      #    value + 5
      #  end
      #
      #  map.call(a: 10) # => Success({ b: 15 })
      #
      # @param input [Any] Value to be mapped
      # @param state [State] Current state
      #
      # @return [Monad::Result]
      def call(state)
        path.call(state) do |inner_state|
          rule.call(inner_state).then do |init|
            fn.reduce(init) do |inner, fn|
              fn[inner]
            end
          end
        end
      end

      # Post-processor for {#call}
      #
      # @example Add 5 to mapped value
      #  class Mapper < Remap
      #    define do
      #      map.adjust do |value|
      #        value + 5
      #      end
      #    end
      #  end
      #
      #  Mapper.call(10) # => 15
      #
      # @yieldparam value [Any] Mapped value
      # @yieldreturn [Monad::Result, Any]
      #
      # @return [void]
      def adjust(&block)
        add do |state|
          state.execute(&block)
        end
      end
      alias then adjust

      def pending(reason = "Pending mapping")
        add do |state|
          state.problem(reason)
        end
      end

      def enum(&block)
        add do |state|
          state.fmap do |id, &error|
            Enum.call(&block).get(id, &error)
          end
        end
      end

      def if(&block)
        add do |state|
          state.execute(&block).fmap do |bool, &error|
            bool ? state.value : error["#if returned false"]
          end
        end
      end

      def if_not(&block)
        add do |state|
          state.execute(&block).fmap do |bool, &error|
            bool ? error["#if_not returned true"] : state.value
          end
        end
      end

      private

      def add(&block)
        tap { fn << block }
      end

      def fn
        @fn ||= []
      end
    end
  end
end
