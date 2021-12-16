# frozen_string_literal: true

module Remap
  class Mapper
    # @abstract
    class Binary < self
      include API

      attribute :left, Types::Mapper
      attribute :right, Types::Mapper

      # @return [Bool]
      def validate?
        left.validate? && right.validate?
      end
    end
  end
end
