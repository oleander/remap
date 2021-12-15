# frozen_string_literal: true

module Remap
  class Rule < Dry::Interface
    using Extensions::Hash
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

    using Module.new {
      refine Object do
        def to_hash
          self
        end
      end

      refine Array do
        def to_hash
          map(&:to_hash)
        end
      end
    }

    def to_hash
      attributes.transform_values(&:to_hash).except(:backtrace)
    end
  end
end
