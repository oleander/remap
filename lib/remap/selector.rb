# frozen_string_literal: true

module Remap
  # Defines how a path element, or selector
  # Specifies how a value is extracted from a state
  class Selector < Dry::Interface
    # Selects value from state, package it as a state and passes it to block
    #
    # @param state [State]
    #
    # @yieldparam [State]
    # @yieldreturn [State]
    #
    # @return [State]
    #
    # @abstract
    def call(state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end
  end
end
