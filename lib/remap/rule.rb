# frozen_string_literal: true

module Remap
  class Rule < Dry::Concrete
    defines :requirement
    requirement Types::Any
  end
end
