# frozen_string_literal: true

describe Remap::Rule do
  describe "::call" do
    context "when passed a rule" do
      subject { described_class.call(rule) }

      let(:rule) { void! }

      it { is_expected.to eq(rule) }
    end
  end
end
