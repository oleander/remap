# frozen_string_literal: true

describe Remap::State do
  describe "::state" do
    context "given valid input" do
      subject { described_class.call(input, mapper: mapper) }

      let(:input) { value! }
      let(:mapper) { mapper! }

      it { is_expected.to include(mapper: mapper) }
      it { is_expected.to include(input: input) }
      it { is_expected.to include(options: {}) }
    end

    context "given invalid input" do
      subject(:result) { described_class.call(value!, mapper: nil) }

      it "raises an argument error" do
        expect { result }.to raise_error(ArgumentError)
      end
    end
  end
end
