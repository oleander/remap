# frozen_string_literal: true

module Remap
  class Result < Dry::Interface
    attribute? :notices, [Notice], default: EMPTY_ARRAY

    # @return [Boolean]
    def problem?
      !notices.blank?
    end
    alias has_problem? problem?

    # @abstract
    #
    # @return [Boolean]
    def success?
      raise NotImplementedError, "success? not implemented"
    end

    # @abstract
    #
    # @return [Boolean]
    def failure?
      raise NotImplementedError, "failure? not implemented"
    end

    # @abstract
    #
    # @yieldparam [T]
    # @yieldreturn [U]
    #
    # @return [Result<Y>]
    def fmap
      raise NotImplementedError, "fmap not implemented"
    end

    # @param other [Result]
    #
    # @return [Result]
    #
    # @abstract
    def merge(other)
      raise NotImplementedError, "merge not implemented"
    end

    # @return [Error]
    #
    # @abstract
    def exception
      raise NotImplementedError, "exception not implemented"
    end
  end
end
