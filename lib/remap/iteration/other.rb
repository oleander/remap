# frozen_string_literal: true

module Remap
  class Iteration
    class Other < Concrete
      attribute :state, Types::State
      attribute :value, Types::Any

      using State::Extension

      # @see Base#map
      def map(&block)
        block[value]._
      end
      alias call map
    end
  end
end
