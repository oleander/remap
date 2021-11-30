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

  describe "#merge" do
    subject(:result) { left.merge(right) }

    let(:reason1) { { base: ["reason1"] } }
    let(:problem1) { { reason: "problem1" } }

    let(:left) { described_class.call(problems: [problem1], reasons: reason1) }

    context "when right is a failure" do
      let(:reason2) { { base: ["reason2"] } }
      let(:problem2) { { reason: "problem2" } }

      let(:right) { described_class.call(problems: [problem2], reasons: reason2) }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(problems: [problem1, problem2]) }
      it { is_expected.to have_attributes(reasons: { base: ["reason1", "reason2"] }) }
    end

    context "when right is a success" do
      let(:right) { Remap::Success.new(result: value!) }

      it "raises an error" do
        expect { result }.to raise_error(ArgumentError)
      end
    end
  end
end
