# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/array/wrap"
require "active_support/proxy_object"

require "dry/configurable"
require "dry/validation"
require "dry/interface"
require "dry/schema"
require "dry/struct"
require "dry/types"
require "dry/monads"
require "zeitwerk"

module Remap
  loader = Zeitwerk::Loader.for_gem
  loader.collapse("#{__dir__}/remap/rule/support")
  loader.collapse("#{__dir__}/remap/mapper/support")
  loader.setup
  loader.eager_load
end
