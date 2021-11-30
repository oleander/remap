# frozen_string_literal: true

module Remap
  class Mapper
    # @abstract
    class Binary < self
      include Operation

      attribute :left, Types::Mapper
      attribute :right, Types::Mapper
    end
  end
end
