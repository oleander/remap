# frozen_string_literal: true

require "simplecov"
require "bundler/setup"
require "factory_bot"
require "remap"
require "pry"

require_relative "factories"
require_relative "support"
require_relative "examples"
require_relative "matchers"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.include Support
  config.include Dry::Monads[:maybe, :result, :do]
  config.filter_run_when_matching :focus
  config.order = :random
  config.example_status_persistence_file_path = ".rspec_status"
  config.include FactoryBot::Syntax::Methods
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end
