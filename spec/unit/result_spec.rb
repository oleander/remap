# frozen_string_literal: true

describe Remap::Result do
  subject(:result) { described_class.call(input) }

  let(:input) { { problems: [{ value: value!, path: [1, 2, 3], reason: "my reason" }] } }

  describe "::call" do
    context "given valid input" do
      subject { described_class.call(input) }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#problem?" do
    subject { described_class.call(input) }

    context "when problems exist" do
      let(:input) { { problems: [{ value: value!, path: [1, 2, 3], reason: "my reason" }] } }

      it { is_expected.to be_problem }
    end

    context "when problem does not exist" do
      let(:input) { { problems: [] } }

      it { is_expected.not_to be_problem }
    end
  end

  describe "#failure?" do
    it "raises an error" do
      expect { result.failure? }.to raise_error(NotImplementedError)
    end
  end

  describe "#success?" do
    it "raises an error" do
      expect { result.success? }.to raise_error(NotImplementedError)
    end
  end

  describe "#fmap" do
    it "raises an error" do
      expect { result.fmap }.to raise_error(NotImplementedError)
    end
  end
end
