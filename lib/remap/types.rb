# frozen_string_literal: true

require "dry/monads/maybe"
require "dry/logic/operations/negation"
require "dry/logic"

module Remap
  module Types
    include Dry::Types()
    using State::Extension

    Enumerable = Any.constrained(type: Enumerable)
    Nothing    = Constant(Remap::Nothing)
    Mapper     = Interface(:call!)
    Key        = Interface(:hash)

    State = Hash.constructor do |value, type, &error|
      type[value, &error]._(&error)
    end

    Problem = Hash.schema(
      reason: String.constrained(min_size: 1),
      path?: Array.constrained(min_size: 1),
      value?: Any
    )
  end
end
