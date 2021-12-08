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
        raise ArgumentError, "Cannot merge %s (%s) with %s (%s)" % [
          self, self.class, other, other.class
        ]
      end

      failure = attributes.deep_merge(other.attributes) do |key, value1, value2|
        case [key, value1, value2]
        in [:failures | :notices, Array, Array]
          value1 + value2
        end
      end

      new(failure)
    end

    def exception
      Error.new(attributes.formated)
    end
  end
end
