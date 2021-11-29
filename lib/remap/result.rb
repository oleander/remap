# frozen_string_literal: true

module Remap
  class Result < Dry::Struct
    attribute :problems, Types.Array(Types::Problem)

    # @return [Boolean]
    def has_problem?
      !problems.blank?
    end

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
    def fmap(&block)
      raise NotImplementedError, "fmap not implemented"
    end
  end
end
