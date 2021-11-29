# frozen_string_literal: true

require "dry/monads/maybe"
require "dry/logic/operations/negation"
require "dry/logic"

module Remap
  module Types
    include Dry::Types()
    include Dry::Logic::Operations

    using State::Extension

    Enumerable = Any.constrained(type: Enumerable)
    Mapper     = Interface(:call!)
    Nothing    = Constant(Remap::Nothing)
    Key        = Interface(:hash)

    State = Hash.constructor do |value, type, &error|
      type[value, &error]._(&error)
    end

    Problem = Hash.schema(
      value?: Any,
      path?: Array.constrained(min_size: 1),
      reason: String.constrained(min_size: 1)
    )
  end
end
