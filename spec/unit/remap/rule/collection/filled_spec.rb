# frozen_string_literal: true

using Remap::State::Extension

describe Remap::Rule::Collection::Filled do
  let(:rule1) { void! }
  let(:rule2) { void! }

  describe "#call" do
    subject { rule.call(state) }

    let(:rule) { described_class.call(rules) }

    context "when state is undefined" do
      let(:state) { undefined! }

      context "when it contains one rule" do
        let(:rules) { [rule1] }

        it { is_expected.not_to have_key(:value) }
      end

      context "when it contains two rules" do
        let(:rules) { [rule1, rule2] }

        it { is_expected.not_to have_key(:value) }
      end
    end

    context "when mixed with a problem" do
      subject { collection.call(state) }

      let(:collection) { described_class.call(rules) }
      let(:input) { { key: "value" } }
      let(:state) { state!(input)    }
      let(:rules) { [rule1, rule2]   }

      context "when left is a problem" do
        let(:value) { { key: "value" } }
        let(:rule1) { problem!       }
        let(:rule2) { static!(value) }

        it { is_expected.to contain(input) }
        it { is_expected.to have(1).problems }
      end

      context "when right is a problem" do
        let(:rule1) { map! { value } }
        let(:rule2) { pending! }

        it { is_expected.to contain(input) }
        it { is_expected.to have(1).problems }
      end

      context "when both are a problem" do
        let(:rule1) { problem! }
        let(:rule2) { problem! }

        it { is_expected.not_to contain(input) }
        it { is_expected.to have(2).problems }
      end
    end

    context "when state contains an array" do
      let(:input) { [1, 2, 3] }

      let(:state) { state!(input) }

      context "when it contains one rule" do
        let(:rules) { [rule1] }

        it { is_expected.to contain(input) }
      end

      context "when it contains two rules" do
        let(:rules) { [rule1, rule2] }

        it { is_expected.to contain(input * 2) }
      end
    end

    context "when state contains a hash" do
      let(:input) { { key1: "value1", key2: "value2" } }

      let(:state) { state!(input) }

      context "when it contains one rule" do
        let(:rules) { [rule1] }

        it { is_expected.to contain(input) }
      end

      context "when it contains two rules" do
        let(:rules) { [void!, void!] }

        it { is_expected.to contain(input) }
      end
    end
  end
end
