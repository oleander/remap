# frozen_string_literal: true

describe Remap::Base do
  subject { mapper.call(input, &error) }

  let(:mapper) do
    mapper! do
      define do
        map [all] do
          map :name
        end
      end
    end
  end

  let(:input) do
    [{ name: "John" }, { name: "Jane" }]
  end

  let(:output) do
    ["John", "Jane"]
  end

  its(:value) { is_expected.to eq(output) }
end
