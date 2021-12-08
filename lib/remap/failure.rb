# frozen_string_literal: true

module Remap
  using Extensions::Hash

  class Failure < Dry::Concrete
    attribute :failures, [Notice], min_size: 1
    attribute? :notices, [Notice], default: EMPTY_ARRAY

    # Merges two failures
    #
    # @param other [Failure]
    #
    # @return [Failure]
    def merge(other)
      unless other.is_a?(self.class)
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

    # @return [String]
    def exception
      Error.new(attributes.formated)
    end
  end
end
