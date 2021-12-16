# frozen_string_literal: true

require "simplecov"

require "active_support/core_ext/hash/deep_transform_values"
require "rspec/collection_matchers"
require "dry/core/class_builder"
require "rspec-benchmark"
require "factory_bot"
require "rspec/its"
require "remap"
require "pry"

require_relative "factories"
require_relative "support"
require_relative "examples"
require_relative "matchers"

class Remap::Base
  configuration do |c|
    c.validation = true
  end
end

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include RSpec::Benchmark::Matchers
  config.include FactoryBot::Syntax::Methods
  config.include Support

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.max_formatted_output_length = nil
  end

  config.example_status_persistence_file_path = ".rspec_status"
  config.order = :random
end
