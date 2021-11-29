# frozen_string_literal: true

if ENV.key?("COVERAGE")
  SimpleCov.start do
    add_filter "spec/matchers.rb"
  end
end
