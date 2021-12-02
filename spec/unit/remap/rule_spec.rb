# frozen_string_literal: true

describe Remap::Rule do
  describe "::call" do
    context "when passed a rule" do
      subject { rule.call(state) }

      let(:rule)  { described_class.call(void!) }
      let(:state) { state!                      }

      it { is_expected.to eq(state) }
    end
  end
end
