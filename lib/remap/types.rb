# frozen_string_literal: true

require "dry/monads/maybe"
require "dry/logic/operations/negation"
require "dry/logic"

module Remap
  # Defines callable types used troughout the application
  module Types
    include Dry::Types()
    using State::Extension

    Enumerable = Any.constrained(type: Enumerable)
    Nothing    = Constant(Remap::Nothing)
    Mapper     = Interface(:call!)
    Rule       = Interface(:call)
    Key        = Interface(:hash)

    State = Hash.constructor do |input, type, &error|
      result = Remap::State::Schema.call(input)
      error ||= ->(error) { raise error }

      if result.success?
        next input
      else
        next error[JSON.pretty_generate(result.errors.to_h)]
      end
    end

    Problem = Hash.schema(
      reason: String.constrained(min_size: 1),
      path?: Array.constrained(min_size: 1),
      value?: Any
    )
  end
end
