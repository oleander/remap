# frozen_string_literal: true

using Remap::State::Extension

describe Remap::Rule::Each do
  describe "::call" do
    subject { described_class.call(rule: rule!) }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    subject(:result) { described_class.call(rule: rule).call(state, &error) }

    context "when state is an array" do
      subject { result.fmap { _1.sort_by(&:to_s) } }

      let(:input) { [3, 2, 1]                         }
      let(:state) { state!(input)                     }
      let(:rule)  { described_class.call(rule: rule!) }

      it { is_expected.not_to include(:element, :index, :key) }

      context "when accessing #value" do
        let(:rule) { map!(&:to_s) }
        let(:output) { ["1", "2", "3"] }

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

    xcontext "when state is not enumerable" do
      let(:rule) { void! }
      let(:value) { int!          }
      let(:state) { state!(value) }

      it "raises an notice error" do
        expect { |b| rule.call(state, &b) }.to yield_control
      end
    end
  end
end
