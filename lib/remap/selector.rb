# frozen_string_literal: true

module Remap
  class Selector < Dry::Interface
    defines :requirement, type: Types::Any.constrained(type: Dry::Types::Type)
    requirement Types::Any

    private

    def requirement
      self.class.requirement
    end
  end
end
