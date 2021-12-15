# frozen_string_literal: true

describe Remap::State do
  describe "::state" do
    context "given valid input" do
      subject { described_class.call(input, mapper: mapper) }

      let(:input)  { value!  }
      let(:mapper) { mapper! }

      it { is_expected.to include(mapper: mapper) }
      it { is_expected.to include(input: input) }
      it { is_expected.to include(options: {}) }
    end
  end
end
