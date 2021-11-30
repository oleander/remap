# frozen_string_literal: true

module Remap
  class Rule
    using State::Extensions::Enumerable
    using State::Extension

    # Maps an input path to an output path
    #
    # @example Map { name: "Ford" } to { person: { name: "Ford" } }
    #   class Mapper < Remap::Base
    #     define do
    #       map :name, to: [:person, :name]
    #     end
    #   end
    #
    #   Mapper.call({ name: "Ford" }).result # => { person: { name: "Ford" } }
    class Map < Concrete
      # @return [Rule]
      attribute :rule, Rule.default { Void.call({}) }

      class Inner < Struct
        attribute :output, Path::Output.default { Path::Output.call([]) }
        attribute :input, Path::Input.default { Path::Input.call([]) }
      end

      # @return [Hash]
      attribute? :path, Inner.default { Inner.call({}) }

      # Maps state using {#path} & {#rule}
      #
      # @param state [State<T>]
      #
      # @return [State<U>]
      def call(state)
        (path.input >> rule >> callback >> path.output).call(state)
      end

      # A post-processor method
      #
      # @example Map "Hello" to "Hello!"
      #   class Mapper < Remap::Base
      #     define do
      #       map.adjust do
      #         "#{value}!"
      #       end
      #     end
      #   end
      #
      #   Mapper.call("Hello").result # => "Hello!"
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
      #   class Mapper < Remap::Base
      #     define do
      #       map(:a, :b).pending
      #     end
      #   end
      #
      #   Mapper.call({ a: { b: "A" } }).problems.count # => 1
      #
      # @return [Map]
      def pending(reason = "Pending mapping")
        add do |state|
          state.problem(reason)
        end
      end

      # An enumeration processor
      #
      # @example Maps { a: { b: "A" } } to "A"
      #   class Mapper < Remap::Base
      #     define do
      #       map(:a, :b).enum do
      #         value "A", "B"
      #       end
      #     end
      #   end
      #
      #   Mapper.call({ a: { b: "A" } }).result # => "A"
      #   Mapper.call({ a: { b: "B" } }).result # => "B"
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
      #   class Mapper < Remap::Base
      #     define do
      #       each do
      #         map.if do
      #           value.include?("B")
      #         end
      #       end
      #     end
      #   end
      #
      #   Mapper.call(["A", "B", "C"]).result # => ["B"]
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
      #   class Mapper < Remap::Base
      #     define do
      #       each do
      #         map.if_not do
      #           value.include?("B")
      #         end
      #       end
      #     end
      #   end

      #   Mapper.call(["A", "B", "C"]).result # => ["A", "C"]
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

      # @return [Proc]
      def callback
        -> state do
          fn.reduce(state) do |inner, fn|
            fn[inner]
          end
        end
      end
    end
  end
end
