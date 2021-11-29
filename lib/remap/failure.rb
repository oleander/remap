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
    def fmap
      self
    end

    def merge(other)
      unless other.is_a?(Failure)
        raise ArgumentError, "can't merge #{self.class} with #{other.class}"
      end

      failure = attributes.deep_merge(other.attributes) do |_, value1, value2|
        case [value1, value2]
        in [Array, Array]
          value1 + value2
        else
          raise ArgumentError, "can't merge #{self.class} with #{other.class}"
        end
      end

      new(failure)
    end
  end
end
