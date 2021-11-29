# frozen_string_literal: true

using Remap::State::Extension

RSpec::Matchers.define :have do |count|
  match do |actual|
    actual.no_of_problems == count
  end

  chain :problems do
    @count = :problems
  end

  # custom error message for failure
  failure_message do |actual|
    detailed = JSON.pretty_generate(actual.problems)
    "expected #{actual} to have #{count} #{@count}, but it has #{actual.no_of_problems}: #{detailed}"
  end

  # custom error message for negative failure
  failure_message_when_negated do |actual|
    detailed = JSON.pretty_generate(actual.problems)
    "expected #{actual} to not have #{count} #{@count}, but it has #{actual.no_of_problems}: #{detailed}"
  end
end

RSpec::Matchers.define :contain do |expected|
  match do |actual|
    (actual.fetch(:value) { return false } === expected || actual.fetch(:value) == expected)
  end

  # custom error message for failure using json pretty print on actual.value
  failure_message do |actual|
    "expected #{JSON.pretty_generate(actual.value)} to contain #{expected}"
  rescue KeyError
    "expected actual to contain #{expected} but it contains nothing"
  end

  # custom error message for negative failure using json pretty print on actual.value
  failure_message_when_negated do |actual|
    "expected #{JSON.pretty_generate(actual.value)} not to contain #{expected}"
  end
end
