# frozen_string_literal: true

if ENV.key?("COVERAGE")
  require "simplecov-json"

  SimpleCov.start do
    add_filter "spec/matchers.rb"

    SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::JSONFormatter
    ])
  end
end
