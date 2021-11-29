# frozen_string_literal: true

describe Remap::Success do
  subject(:success) { described_class.call(input) }

  let(:input) { { problems: [], result: value! } }

  describe "::call" do
    context "given valid input" do
      subject { described_class.call(input) }

      let(:input) { { problems: [], result: value! } }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#failure?" do
    it { is_expected.not_to be_a_failure }
  end

  describe "#success?" do
    it { is_expected.to be_a_success }
  end

  describe "#fmap" do
    it "does not invoke block" do
      expect { |b| success.fmap(&b) }.to yield_control
    end

    it "returns itself" do
      expect(success.fmap(&:itself)).to eq(success)
    end
  end
end
