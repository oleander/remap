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
    Mapper     = Interface(:call!) # Class.constrained(lt: Remap::Mapper) | Instance(Remap::Mapper).constructor { |v, &e| Instance(Remap::Mapper::Binary).call(v, &e) }
    Nothing    = Constant(Remap::Nothing)
    Maybe      = Instance(Dry::Monads::Maybe).fallback(&Dry::Monads::Maybe)
    # Remap      = Class.constrained(lt: Remap)
    Proc       = Instance(Proc)
    Key        = Interface(:hash) | Integer
    Problem    = Hash.schema(value?: Any, path: Array.constrained(min_size: 1), reason: String.constrained(min_size: 1))
    Value = Any # .constrained(not_eql: nil)

    State = Hash.constructor do |value, type, &error|
      type[value, &error]._(&error)
    end

    Selectors = Array.of(Remap::Selector)

    Dry::Types.define_builder(:not) do |type, owner = Object|
      type.constrained_type.new(Instance(owner), rule: Negation.new(type.rule))
    end

    module Report
      include Dry.Types()

      Problem = Hash.schema(value?: Any, reason: String)

      Key = String | Symbol | Integer

      Value = Any.constructor do |value, &error|
        (Array(Problem) | Self).call(value, &error)
      end

      Self = Hash.map(Key, Value) | Hash.schema(base: Array(Problem))
    end
  end
end
