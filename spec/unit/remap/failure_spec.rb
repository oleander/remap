# frozen_string_literal: true

describe Remap::Failure do
  subject(:failure) { described_class.call(input) }

  let(:problem) { { value: value!, path: [:a], reason: string! } }
  let(:input)   { { notices: [], failures: [problem] }           }

  describe "::call" do
    context "given valid input" do
      subject { described_class.call(input) }

      let(:input) { { notices: [], failures: [problem] } }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#merge" do
    subject(:result) { left.merge(right) }

    let(:reason1) { notice! }
    let(:notice1) { notice! }

    let(:left) do
      described_class.call(notices: [notice1], failures: [reason1])
    end

    context "when right is a failure" do
      let(:reason2) { notice! }
      let(:notice2) { notice! }

      let(:right) do
        described_class.call(notices: [notice2], failures: [reason2])
      end

      it { is_expected.to be_a(described_class) }

      it {
        expect(result).to have_attributes(notices: contain_exactly(notice1, notice2))
      }

      it { is_expected.to have_attributes(failures: be_a(Array)) }
    end
  end
end
