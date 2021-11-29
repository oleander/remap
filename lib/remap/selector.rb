# frozen_string_literal: true

module Remap
  # Defines how a path element, or selector
  # Specifies how a value is extracted from a state
  class Selector < Dry::Interface
    defines :requirement, type: Types::Any.constrained(type: Dry::Types::Type)
    requirement Types::Any

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
    def call(_state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end

    private

    # @return [Dry::Types::Type]
    def requirement
      self.class.requirement
    end
  end
end
