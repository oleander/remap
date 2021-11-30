# frozen_string_literal: true

require "simplecov"

require "dry/core/class_builder"
require "rspec/its"
require "factory_bot"
require "remap"
require "pry"

require_relative "factories"
require_relative "support"
require_relative "examples"
require_relative "matchers"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.include Dry::Monads[:maybe, :result, :do]
  config.include FactoryBot::Syntax::Methods
  config.include Support

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.full_backtrace = true

  config.example_status_persistence_file_path = ".rspec_status"
  config.order = :random
end
