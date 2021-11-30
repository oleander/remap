# frozen_string_literal: true

module Remap
  class Constructor
    # Fallback type used by {Remap::Base}
    class None < Concrete
      attribute :target, Types::Nothing
      attribute :strategy, Types::Any
      attribute :method, Types::Any

      # Used by {Remap::Base} as a fallback constructor
      # Using it does nothing but return its input state
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state
      end
    end
  end
end
