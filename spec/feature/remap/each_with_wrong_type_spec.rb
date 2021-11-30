# frozen_string_literal: true

describe Remap::Base do
  subject { mapper.call(input) }

  let(:mapper) do
    mapper! do
      define do
        set to: value([1, 2, 3])
        each do
          map? :names
        end
      end
    end
  end

  let(:input) do
    "not-an-array"
  end

  let(:output) do
    be_a_failure.and(have_attributes(failures: be_present))
  end

  it { is_expected.to match(output) }
end
