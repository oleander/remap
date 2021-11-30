# frozen_string_literal: true

module Remap
  class Rule
    # Maps an input path to an output path
    #
    # @example Map { name: "Ford" } to { person: { name: "Ford" } }
    #   map :name, to: [:person, :name]
    class Map < self
      using State::Extensions::Enumerable
      using State::Extension

      attribute :path do
        attribute :output, Remap::Path::Output, default: -> { Path::Output.new(EMPTY_ARRAY) }
        attribute :input, Remap::Path::Input, default: -> { Path::Input.new(EMPTY_ARRAY) }
      end

      attribute :rule, Types::Rule

      # Maps {state} using {#path} & {#rule}
      #
      # @param state [State<T>]
      #
      # @return [State<U>]
      def call(state)
        path.input.call(state).then(&rule).then do |init|
          fn.reduce(init) do |inner, fn|
            fn[inner]
          end
        end.then(&path.output)
      end

      # A post-processor method
      #
      # @example Map "Hello" to "Hello!"
      #   map.adjust { "#{value}!" }
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
      #
      # @example Ignore rule for input { a: { b: "A" } }
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
      #   each do
      #     map.if { value.include?("B") }
      #   end
      #
      # @return [Map]
      def if(&block)
        add do |state|
          state.execute(&block).fmap do |bool, &error|
            bool ? state.value : error["#if returned false"]
          end
        end
      end

      # Keeps map, only if block is false
      #
      # @example Maps ["A", "B", "C"] to ["A", "C"]
      #   each do
      #     map.if_not { value.include?("B") }
      #   end
      #
      # @return [Map]
      def if_not(&block)
        add do |state|
          state.execute(&block).fmap do |bool, &error|
            bool ? error["#if_not returned true"] : state.value
          end
        end
      end

      private

      # @return [self]
      def add(&block)
        tap { fn << block }
      end

      # @return [Array<Proc>]
      def fn
        @fn ||= []
      end
    end
  end
end
