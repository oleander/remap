# frozen_string_literal: true

describe Remap::Failure do
  subject(:failure) { described_class.call(input) }

  let(:problem) { notice!(value: value!, path: [:a], reason: string!) }
  let(:input)   { { notices: [], failures: [problem] } }

  describe "::call" do
    context "given valid input" do
      subject { described_class.call(input) }

      let(:input) { { notices: [], failures: [problem] } }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#merge" do
    subject(:result) { failure.merge(other) }

    let(:reason1) { notice! }
    let(:notice1) { notice! }

    let(:failure) do
      described_class.call(notices: [notice1], failures: [reason1])
    end

    context "when merged with a failure" do
      let(:reason2) { notice! }
      let(:notice2) { notice! }

      let(:other) do
        described_class.call(notices: [notice2], failures: [reason2])
      end

      it { is_expected.to be_a(described_class) }

      its(:notices) { is_expected.to match_array([notice1, notice2]) }
      its(:failures) { is_expected.to match_array([reason1, reason2]) }
    end

    context "when merged with a non-failure" do
      let(:other) { string! }

      it "raises an argument error" do
        expect { result }.to raise_error(ArgumentError)
      end
    end
  end
end
