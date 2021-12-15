# frozen_string_literal: true

module Remap
  class Constructor
    using State::Extension

    # Allows a class (target) to be called with keyword arguments
    class Keyword < Concrete
      # @return [:keyword]
      attribute :strategy, Value(:keyword)

      # Calls {#target} as with keyword arguments
      #
      # Fails if {#target} does not respond to {#method}
      # Fails if {#target} cannot be called with state
      #
      # Used by {Remap::Base} to define constructors for mapped data
      #
      # @example Initialize a target with a state
      #   target = OpenStruct
      #   constructor = Remap::Constructor.call(strategy: :keyword, target: target, method: :new)
      #   state = Remap::State.call({ foo: :bar })
      #   new_state = constructor.call(state)
      #   new_state.fetch(:value).foo # => :bar
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        super.fmap do |input|
          unless input.is_a?(Hash)
            raise ArgumentError, "Expected Hash, got #{input.class}"
          end

          target.public_send(id, **input)
        end
      end
    end
  end
end
