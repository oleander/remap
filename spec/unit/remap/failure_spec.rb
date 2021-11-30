# frozen_string_literal: true

describe Remap::Failure do
  subject(:failure) { described_class.call(input) }

  let(:problem) { { value: value!, path: [:a], reason: string! } }
  let(:input) { { notices: [], failures: [problem] } }

  describe "::call" do
    context "given valid input" do
      subject { described_class.call(input) }

      let(:input) { { notices: [], failures: [problem] } }

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

    let(:reason1) { notice! }
    let(:notice1) { notice! }

    let(:left) { described_class.call(notices: [notice1], failures: [reason1]) }

    context "when right is a failure" do
      let(:reason2) { notice! }
      let(:notice2) { notice! }

      let(:right) { described_class.call(notices: [notice2], failures: [reason2]) }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(notices: contain_exactly(notice1, notice2)) }
      it { is_expected.to have_attributes(failures: be_a(Array)) }
    end

    context "when right is a success" do
      let(:right) { Remap::Success.new(value: value!) }

      it "raises an error" do
        expect { result }.to raise_error(ArgumentError)
      end
    end
  end
end
