# frozen_string_literal: true

require "dry/monads/maybe"
require "dry/logic/operations/negation"
require "dry/logic"

module Remap
  # Defines callable types used throughout the application
  module Types
    include Dry::Types()
    using State::Extension

    Backtrace  = Array(Interface(:to_s) | String)
    Enumerable = Any.constrained(type: Enumerable)
    Nothing    = Constant(Remap::Nothing)
    Mapper     = Interface(:call!)
    Rule       = Interface(:call)
    Key        = Interface(:hash)

    # Validates a state according to State::Schema
    State = Hash.constructor do |input, type, &error|
      input = type.call(input, &error)
      result = Remap::State::Schema.call(input)
      error ||= -> { raise _1 }

      next input if result.success?

      error[JSON.pretty_generate(result.errors.to_h)]
    end
  end
end
