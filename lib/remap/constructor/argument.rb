# frozen_string_literal: true

module Remap
  class Constructor
    using State::Extension

    # Allows a class (target) to be called with a regular argument
    class Argument < Concrete
      attribute :strategy, Value(:argument), default: :argument

      # Uses the {#method} method to initialize {#target} with {state}
      # Target is only called if {state} is defined
      #
      # Used by {Remap::Base} to define constructors for mapped data
      #
      # Fails if {#target} does not respond to {#method}
      # Fails if {#target} cannot be called with {state}
      #
      # @example Initialize a target with a state
      #   target = Struct.new(:foo)
      #   constructor = Remap::Constructor.call(strategy: :argument, target: target, method: :new)
      #   state = Remap::State.call(foo: :bar)
      #   new_state = constructor.call(state)
      #   new_state.value # => #<struct foo=:bar>
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        super.fmap do |input|
          target.public_send(id, input)
        rescue ArgumentError => e
          raise e.exception("Failed to create [#{target.inspect}] with input [#{input}] (#{input.class})")
        end
      end
    end
  end
end
