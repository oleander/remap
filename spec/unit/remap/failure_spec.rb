# frozen_string_literal: true

describe Remap::Failure do
  subject(:failure) { described_class.call(input) }

  let(:input) { { problems: [], reasons: { base: ["reason"] } } }

  describe "::call" do
    context "given valid input" do
      subject { described_class.call(input) }

      let(:input) { { problems: [], reasons: { base: ["reason"] } } }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#failure?" do
    it { is_expected.to be_failure }
  end

  describe "#success?" do
    it { is_expected.not_to be_a_success }
  end

  describe "#fmap" do
    it "does not invoke block" do
      expect { |b| failure.fmap(&b) }.not_to yield_control
    end

    it "returns itself" do
      expect(failure.fmap).to be(failure)
    end
  end
end
