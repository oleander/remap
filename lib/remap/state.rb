# frozen_string_literal: true

require "dry/schema"
require "dry/validation"
require "dry/core/constants"
require "factory_bot"
require "dry/logic"
require "dry/logic/operations"
require "dry/logic/predicates"
require "json"

module Remap
  # Represents the current state of a mapping
  module State
    using Extension

    include Dry::Core::Constants

    class Dummy < Remap::Base
      # NOP
    end

    # Creates a valid state
    #
    # @param value [Any] Internal state value
    #
    # @option mapper [Mapper::Class] Mapper class
    # @option options [Hash] Mapper options / arguments
    #
    # @return [Hash] A valid state
    def self.call(value, mapper: Dummy, options: EMPTY_HASH)
      {
        notices: EMPTY_ARRAY,
        path: EMPTY_ARRAY,
        options: options,
        mapper: mapper,
        values: value,
        value: value,
        input: value
      }._
    end
  end
end
