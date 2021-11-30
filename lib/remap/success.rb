# frozen_string_literal: true

module Remap
  # Represents a successful mapped result
  class Success < Result::Concrete
    # @return [Array<Notice>]
    attribute? :failures, [Notice], size: 0, default: EMPTY_ARRAY

    # @return [Array<Notice>]
    attribute? :notices, [Notice], default: EMPTY_ARRAY

    # @return [Any]
    attribute :value, Types::Any, alias: :result

    # @return [false]
    def failure?
      false
    end

    # @return [true]
    def success?
      true
    end

    # Calls block with {#value} and returns a other success
    #
    # @yieldparam [T]
    # @yieldreturn [U]
    #
    # @return [Success<U>]
    def fmap(&block)
      new(value: block[value])
    end
  end
end
