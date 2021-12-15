# frozen_string_literal: true

module Remap
  using Extensions::Hash

  class Failure < Dry::Concrete
    attribute :failures, Types.Array(Types::Notice), min_size: 1
    attribute? :notices, Types.Array(Types::Notice), default: EMPTY_ARRAY

    # Merges two failures and returns a new failure
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

    class Error < Error
      extend Dry::Initializer

      option :failure, type: Types.Instance(Failure)
      delegate :inspect, :to_s, to: :failure
      delegate_missing_to :failure
    end

    # @return [Error]
    def exception(backtrace)
      e = Error.new(failure: self)
      e.set_backtrace(backtrace)
      e
    end
  end
end
