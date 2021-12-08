# frozen_string_literal: true

module Remap
  class Rule < Dry::Interface
    defines :requirement
    requirement Types::Any

    # @param state [State]
    #
    # @abstract
    def call(state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end
  end
end
