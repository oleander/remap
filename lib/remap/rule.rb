# frozen_string_literal: true

module Remap
  class Rule < Dry::Concrete
    defines :requirement
    requirement Types::Any

    # @param state [State]
    #
    # @abstract
    def call(state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end

    # @return [Proc]
    def to_proc
      method(:call).to_proc
    end
  end
end
