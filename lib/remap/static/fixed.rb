# frozen_string_literal: true

module Remap
  class Static
    using State::Extension

    # Maps a fixed value to state
    #
    # @example Map a fixed value to path
    #   set :a, :b, to: value('a value')
    class Fixed < Concrete
      # @return [Any]
      attribute :value, Types::Any

      # Set state to {#value}
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state.set(value)
      end
    end
  end
end
