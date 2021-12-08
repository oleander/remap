# frozen_string_literal: true

using Remap::State::Extension
using Remap::Extensions::Hash
using Remap::Extensions::Object

RSpec::Matchers.define :contain do |expected|
  match do |actual|
    (actual.fetch(:value) do
       return false
     end === expected || actual.fetch(:value) == expected)
  end

  failure_message do |actual|
    "expected #{actual.value.formated} to contain #{expected}"
  rescue KeyError
    "expected actual to contain #{expected} but it contains nothing"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.value.formated} not to contain #{expected}"
  end
end
