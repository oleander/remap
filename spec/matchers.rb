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
    "expected #{actual.value.formatted} to contain #{expected}"
  rescue KeyError
    "expected actual to contain #{expected} but it contains nothing"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.value.formatted} not to contain #{expected}"
  end
end

RSpec::Matchers.define :yield_and_return do |value|
  callback         = proc(&:itself)
  and_return_check = -> _ { true }
  actual           = nil
  and_return_value = "anything"
  returned         = "nothing"

  inner = -> v1 do
    callback[v1].tap do |v2|
      actual = v2
    end
  end

  match do |probe|
    returned = probe[inner]
    and_return_check[returned]

    values_match?(value, actual) && and_return_check[returned]
  end

  chain :with_proc do |&a_callback|
    callback = a_callback
  end

  chain :and_return do |v1|
    and_return_value = v1
    and_return_check = -> v2 do
      v1 === v2
    end
  end

  failure_message do
    "expected to receive %s & %s to be returned but %s were yielded & %s returned" % [
      surface_descriptions_in(value),
      surface_descriptions_in(and_return_value),
      surface_descriptions_in(actual),
      surface_descriptions_in(returned)
    ]
  end

  def supports_block_expectations?
    true
  end
end
