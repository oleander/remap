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
          raise e.exception("Could not load target [#{target}] using the keyword strategy using [#{input}] (#{input.class})")
        end
      end
    end
  end
end
