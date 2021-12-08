# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Set path to a static value
    #
    # @example Set path [:a, :b] to value "C"
    #   value = Remap::Static::Fixed.new(value: "a value")
    #   set = Remap::Rule::Set.new(value: value, path: [:a, :b])
    #   state = Remap::State.call("ANY VALUE")
    #   set.call(state).fetch(:value) # => { a: { b: "a value" } }
    #
    # @example Set path [:a, :b] to option :c
    #   value = Remap::Static::Option.new(name: :c)
    #   set = Remap::Rule::Set.new(value: value, path: [:a, :b])
    #   state = Remap::State.call("ANY VALUE", options: { c: "C" })
    #   set.call(state).fetch(:value) # => { a: { b: "C" } }
    class Set < Concrete
      # @return [Static]
      attribute :value, Static, alias: :rule

      # @return [Path::Output]
      attribute :path, Path::Output

      # @see Rule#call
      def call(...)
        rule.call(...).then(&path)
      end
    end
  end
end
