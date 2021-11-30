# frozen_string_literal: true

module Remap
  # Represents a successful mapped result
  class Success < Result
    # @return [Any]
    attribute :result, Types::Any

    # @return [false]
    def failure?
      false
    end

    # @return [true]
    def success?
      true
    end

    # Calls block with {#result} and returns a other success
    #
    # @yieldparam [T]
    # @yieldreturn [U]
    #
    # @return [Success<U>]
    def fmap(&block)
      new(result: block[result])
    end
  end
end
