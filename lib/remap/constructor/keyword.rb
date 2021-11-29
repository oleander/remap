# frozen_string_literal: true

module Remap
  class Constructor
    class Keyword < Concrete
      using State::Extension

      attribute :strategy, Value(:keyword)

      # Calls {#target} as with keyword arguments
      #
      # Fails if {#target} does not respond to {#method}
      # Fails if {#target} cannot be called with {state}
      #
      # Used by {Remap::Base} to define constructors for mapped data
      #
      # @example Initialize a target with a state
      #   target = OpenStruct
      #   constructor = Remap::Constructor.call(strategy: :keyword, target: target, method: :new)
      #   state = Remap::State.call({ foo: :bar })
      #   new_state = constructor.call(state)
      #   new_state.value # => #<OpenStruct foo=:bar>
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        super.fmap do |input, &error|
          unless input.is_a?(Hash)
            return error["Input is not a hash"]
          end

          target.public_send(id, **input)
        rescue ArgumentError => e
          raise e.exception("Failed to create [#{target.inspect}] with input [#{input}] (#{input.class})")
        end
      end
    end
  end
end
