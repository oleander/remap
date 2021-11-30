# frozen_string_literal: true

module Remap
  class Rule < Dry::Concrete
    defines :requirement
    requirement Types::Any

    # @return [Proc]
    def to_proc
      method(:call).to_proc
    end
  end
end
