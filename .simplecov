# frozen_string_literal: true

if ENV.key?("COVERAGE")
  require "simplecov-cobertura"

  SimpleCov.start do
    add_filter "spec/matchers.rb"
    enable_coverage :branch
    primary_coverage :branch

    SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::CoberturaFormatter,
      SimpleCov::Formatter::HTMLFormatter
    ])
  end
end
