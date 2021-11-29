# frozen_string_literal: true

SimpleCov.start do
  add_filter "spec/matchers.rb"
end if ENV.key?("COVERAGE")
