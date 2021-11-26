# frozen_string_literal: true

using Remap::State::Extension

describe Remap::Rule::Each do
  describe "::call" do
    subject { described_class.call(rule: rule!) }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    subject(:result) { described_class.call(rule: rule).call(state) }

    context "when state is an array" do
      subject { result.fmap { _1.sort_by(&:to_s) } }

      let(:input) { [3, 2, 1] }
      let(:state) { state!(input) }

      context "when accessing #value" do
        let(:rule) { map!(&:to_s) }
        let(:output) { %w[1 2 3] }

        it { is_expected.to contain(output) }
      end

      context "when accessing #index" do
        let(:rule) { map! { index } }
        let(:output) { [0, 1, 2] }

        it { is_expected.to contain(output) }
      end

      context "when accessing #element" do
        let(:rule) { map! { element } }
        let(:output) { [1, 2, 3] }

        it { is_expected.to contain(output) }
      end
    end

    context "when state is an hash" do
      let(:input) { { a: 1, b: 2, c: 3 } }
      let(:state) { state!(input) }

      context "when accessing #value" do
        let(:rule) { map!(&:to_s) }
        let(:output) { input.transform_values(&:to_s) }

        it { is_expected.to contain(output) }
      end

      context "when accessing #key" do
        let(:rule) { map! { key.to_s } }
        let(:output) { { a: "a", b: "b", c: "c" } }

        it { is_expected.to contain(output) }
      end
    end

    context "when state is not enumerable" do
      let(:rule) { rule! }
      let(:value) { int! }
      let(:state) { state!(value) }

      context "when accessing #value" do
        let(:output) { value.to_s }
        let(:rule) { map!(&:to_s) }

        it { is_expected.to have(0).problems }
        it { is_expected.to contain(output) }
      end

      context "when accessing #element" do
        let(:output) { value.to_s }
        let(:rule) { map!(&:to_s) }

        it { is_expected.to have(0).problems }
        it { is_expected.to contain(output) }
      end

      context "when accessing #key" do
        let(:rule) { map! { key } }

        it { is_expected.to have(1).problems }
      end

      context "when accessing #index" do
        let(:rule) { map! { index } }

        it { is_expected.to have(1).problems }
      end
    end
  end
end
