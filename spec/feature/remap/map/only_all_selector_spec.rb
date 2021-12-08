# frozen_string_literal: true

describe Remap::Base do
  subject { mapper.call(input, &error) }

  let(:mapper) do
    mapper! do
      define do
        map all
      end
    end
  end

  let(:input) do
    [{ name: "John" }, { name: "Jane" }]
  end

  let(:output) do
    input
  end

  it { is_expected.to eq(output) }
end
