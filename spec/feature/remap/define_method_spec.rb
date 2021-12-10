# frozen_string_literal: true

describe Remap do
  it_behaves_like described_class::Base do
    let(:mapper) do
      described_class.define OpenStruct do
        map :a, to: :b
      end
    end

    let(:input) do
      { a: 'value' }
    end

    let(:output) do
      have_attributes(b: 'value')
    end
  end
end
