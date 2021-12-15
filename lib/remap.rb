# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/array/wrap"
require "active_support/proxy_object"

require "dry/validation"
require "dry/interface"
require "dry/schema"
require "dry/struct"
require "dry/monads"
require "dry/types"

require "neatjson"
require "zeitwerk"

module Remap
  loader = Zeitwerk::Loader.for_gem
  loader.collapse("#{__dir__}/remap/mapper/support")
  loader.setup
  loader.inflector.inflect "api" => "API"
  loader.eager_load

  include ClassInterface
  module_function :define
end
