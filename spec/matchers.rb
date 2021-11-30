# frozen_string_literal: true

using Remap::State::Extension

RSpec::Matchers.define :have do |count|
  match do |actual|
    actual.notices.count == count
  end

  chain :problems do
    @count = :problems
  end
end

RSpec::Matchers.define :contain do |expected|
  match do |actual|
    (actual.fetch(:value) { return false } === expected || actual.fetch(:value) == expected)
  end

  failure_message do |actual|
    "expected #{JSON.pretty_generate(actual.value)} to contain #{expected}"
  rescue KeyError
    "expected actual to contain #{expected} but it contains nothing"
  end

  failure_message_when_negated do |actual|
    "expected #{JSON.pretty_generate(actual.value)} not to contain #{expected}"
  end
end
