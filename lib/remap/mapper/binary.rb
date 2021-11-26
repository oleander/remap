# frozen_string_literal: true

module Remap
  class Mapper
    class Binary < self
      attribute :left, Types::Mapper
      attribute :right, Types::Mapper

      def exception
        ->(error) { raise error }
      end

      include Operation
    end
  end
end
