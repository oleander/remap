# frozen_string_literal: true

describe Remap::Result do
  subject(:result) { described_class.call(input) }

  let(:input) do
    {
      value: value!,
      notices: [{ value: value!, path: [1, 2, 3], reason: "my reason" }]
    }
  end

  describe "::call" do
    context "given valid input" do
      subject { described_class.call(input) }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#problem?" do
    subject { described_class.call(input) }

    context "when notices exist" do
      let(:input) do
        {
          value: value!,
          notices: [{ value: value!, path: [1, 2, 3], reason: "my reason" }]
        }
      end

      it { is_expected.to be_problem }
    end

    context "when problem does not exist" do
      let(:input) { { value: value!, notices: [] } }

      it { is_expected.not_to be_problem }
    end
  end
end
