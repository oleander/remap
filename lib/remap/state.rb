# frozen_string_literal: true

require "dry/schema"
require "dry/validation"
require "dry/core/constants"
require "factory_bot"
require "dry/logic"
require "dry/logic/operations"
require "dry/logic/predicates"
require "json"
require "pry"

module Remap
  module State
    include Dry::Core::Constants
    using Extension

    def state(value, mapper:, options: {})
      { value: value, input: value, mapper: mapper, problems: [], path: [], options: options, values: value }._
    end
    alias call state
    module_function :state, :call
  end
end
