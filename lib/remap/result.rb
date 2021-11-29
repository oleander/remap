# frozen_string_literal: true

module Remap
  class Result < Dry::Struct
    attribute? :problems, Types.Array(Types::Problem).default { EMPTY_ARRAY }

    # @return [Boolean]
    def problem?
      !problems.blank?
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
  end
end
