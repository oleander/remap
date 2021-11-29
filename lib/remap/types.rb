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
    Maybe      = Instance(Dry::Monads::Maybe).fallback(&Dry::Monads::Maybe)
    Proc       = Instance(Proc)
    Key        = Interface(:hash)

    Value      = Any

    State = Hash.constructor do |value, type, &error|
      type[value, &error]._(&error)
    end

    Problem    = Hash.schema(
      value?: Any,
      path?: Array.constrained(min_size: 1),
      reason: String.constrained(min_size: 1)
    )

    Selectors = Array.of(Remap::Selector)

    Dry::Types.define_builder(:not) do |type, owner = Object|
      type.constrained_type.new(Instance(owner), rule: Negation.new(type.rule))
    end
  end
end
