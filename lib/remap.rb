# frozen_string_literal: true

require "dry/struct"
require "dry/validation"

require "active_support/core_ext/module/delegation"
require "dry/core/class_builder"
# require "dry/core/memoizable"
require "dry/logic/builder"
require "dry/configurable"
require "dry/interface"
require "dry/schema"
require "dry/types"
require "dry/monads"
require "dry/logic"
require "zeitwerk"

Dry::Types.load_extensions(:maybe)

loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/remap/rule/support")
loader.setup

module Remap
end

loader.eager_load
