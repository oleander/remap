# frozen_string_literal: true

describe Remap::State do
  include described_class

  describe "::state" do
    subject { state(input, mapper: mapper) }

    let(:input) { value! }
    let(:mapper) { mapper! }

    it { is_expected.to include(mapper: mapper) }
    it { is_expected.to include(input: input) }
    it { is_expected.to include(options: {}) }
  end
end
