# frozen_string_literal: true

module Remap
  class Rule < Dry::Interface
    using Extensions::Hash
    using Extensions::Array
    using Extensions::Object
    include Catchable
    defines :requirement
    requirement Types::Any

    VOID = Void.new(EMPTY_HASH)

    # @param state [State]
    #
    # @abstract
    def call(state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end

    # @return [String]
    def inspect
      "#<#{self.class} #{to_hash.formatted}>"
    end
    alias to_s inspect

    # @return [Hash]
    def to_hash
      attributes.transform_values(&:to_hash).except(:backtrace)
    end
  end
end
