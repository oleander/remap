# frozen_string_literal: true

module Remap
  using Extensions::Hash

  class Failure < Result::Concrete
    attribute :failures, [Notice], min_size: 1
    attribute? :notices, [Notice], default: EMPTY_ARRAY

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

    # Checks if any failures exists
    #
    # @return [Boolean]
    def has_problem?
      super || failures.any?
    end

    # Merges two failures
    #
    # @param other [Failure]
    #
    # @return [Failure]
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

    # @return [String]
    def exception
      Error.new(attributes.formated)
    end
  end
end
