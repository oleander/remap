# frozen_string_literal: true

module Remap
  class Failure < Result
    attribute :reasons, Types::Hash

    # @return [true]
    def failure?
      true
    end

    # @return [false]
    def success?
      false
    end

    # @return [self]
    def fmap(&block)
      self
    end
  end
end
