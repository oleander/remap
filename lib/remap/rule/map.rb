# frozen_string_literal: true

module Remap
  class Rule
    # Maps an input path to an output path
    #
    # @example Map { name: "Ford" } to { person: { name: "Ford" } }
    #   map :name, to: [:person, :name]
    class Map < self
      using State::Extension

      attribute :rule, Types::Rule
      attribute :path, Path

      # Maps {state} using {#path} & {#rule}
      #
      # @param state [State<T>]
      #
      # @return [State<U>]
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
      # @yieldparam value [U]
      # @yieldreturn [T]
      #
      # @return [Map]
      def adjust(&block)
        add do |state|
          state.execute(&block)
        end
      end
      alias then adjust

      # A pending rule
      #
      # @param reason [String]

      # @example A pending rule
      #   map(:a, :b).pending
      #
      # @return [Map]
      def pending(reason = "Pending mapping")
        add do |state|
          state.problem(reason)
        end
      end

      # An enum processor
      #
      # @example Maps { a: { b: "A" } } to "A"
      #   map(:a, :b).enum do
      #     value "A", "B"
      #   end
      #
      # @return [Map]
      def enum(&block)
        add do |state|
          state.fmap do |id, &error|
            Enum.call(&block).get(id, &error)
          end
        end
      end

      # Keeps map, only if block is true
      #
      # @example Maps ["A", "B", "C"] to ["B"]
      #   map.if { value.include?("B") }
      #
      # @return [Map]
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
