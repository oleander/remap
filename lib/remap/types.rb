# frozen_string_literal: true

require "dry/logic/operations/negation"
require "dry/logic"

module Remap
  # Defines callable types used throughout the application
  module Types
    include Dry::Types()
    using State::Extension
    using Extensions::Hash

    Backtrace  = Array(Interface(:to_s) | String)
    Enumerable = Any.constrained(type: Enumerable)
    Nothing    = Constant(Remap::Nothing)
    Mapper     = Interface(:call!)
    Rule       = Interface(:call) | Instance(Proc)
    Key        = Interface(:hash)
    Notice     = Instance(Remap::Notice)
    ID         = String | Symbol

    # Validates a state according to State::Schema
    State = Hash.constructor do |input, type, &error|
      input = type.call(input, &error)
      result = Remap::State::Schema.call(input)
      error ||= -> { raise _1 }

      next input if result.success?

      error[result.errors.to_h.formatted]
    end
  end
end
