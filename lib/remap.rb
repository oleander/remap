# frozen_string_literal: true


require "active_support/core_ext/module/delegation"
require "dry/validation"
require "dry/interface"
require "dry/schema"
require "dry/struct"
require "dry/types"
require "dry/monads"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/remap/rule/support")
loader.setup

module Remap
end

loader.eager_load
