# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        contract do
          required(:people).filled(:array)
        end
      end
    end

    let(:input) do
      { people: { name: "John" } }
    end

    let(:output) do
      { failure: { people: be_a(Array) } }
    end
  end
end
