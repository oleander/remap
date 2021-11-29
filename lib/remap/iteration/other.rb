# frozen_string_literal: true

module Remap
  class Iteration
    class Other < Concrete
      attribute :state, Types::State
      attribute :value, Types::Any

      using State::Extension

      # @see Base#map
      def call(&block)
        block[value]._
      end
    end
  end
end
