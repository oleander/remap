# frozen_string_literal: true

module Remap
  class Rule < Dry::Interface
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

  end
end
