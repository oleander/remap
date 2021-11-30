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

      class LocalPath < Struct
        attribute :output, Path::Output.default { Path::Output.call([]) }
        attribute :input, Path::Input.default { Path::Input.call([]) }
      end

      # @return [Hash]
      attribute? :path, LocalPath.default { LocalPath.call({}) }

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
      # @example Upcase mapped value
      #   state = Remap::State.call("Hello World")
      #   map = Remap::Rule::Map.call({})
      #   upcase = map.adjust(&:upcase)
      #   upcase.call(state).fetch(:value) # => "HELLO WORLD"
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
      # @example Pending mapping
      #   state = Remap::State.call(:value)
      #   map = Remap::Rule::Map.call({})
      #   pending = map.pending("this is pending")
      #   pending.call(state).key?(:value) # => false
      #
      # @return [Map]
      def pending(reason = "Pending mapping")
        add do |state|
          state.problem(reason)
        end
      end

      # An enumeration processor
      #
      # @example A mapped enum
      #   enum = Remap::Rule::Map.call({}).enum do
      #     value "A", "B"
      #     otherwise "C"
      #   end
      #
      #   a = Remap::State.call("A")
      #   enum.call(a).fetch(:value) # => "A"
      #
      #   b = Remap::State.call("B")
      #   enum.call(b).fetch(:value) # => "B"
      #
      #   c = Remap::State.call("C")
      #   enum.call(c).fetch(:value) # => "C"
      #
      #   d = Remap::State.call("D")
      #   enum.call(d).fetch(:value) # => "C"
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
      # @example Keep if value contains "A"
      #   map = Remap::Rule::Map.call({}).if do
      #     value.include?("A")
      #   end
      #
      #   a = Remap::State.call("A")
      #   map.call(a).fetch(:value) # => "A"
      #
      #   b = Remap::State.call("BA")
      #   map.call(b).fetch(:value) # => "BA"
      #
      #   c = Remap::State.call("C")
      #   map.call(c).key?(:value) # => false
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

      # @example Keep unless value contains "A"
      #   map = Remap::Rule::Map.call({}).if_not do
      #     value.include?("A")
      #   end
      #
      #   a = Remap::State.call("A")
      #   map.call(a).key?(:value) # => false
      #
      #   b = Remap::State.call("BA")
      #   map.call(b).key?(:value) # => false
      #
      #   c = Remap::State.call("C")
      #   map.call(c).fetch(:value) # => "C"
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
