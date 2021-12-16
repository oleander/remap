# frozen_string_literal: true

describe Remap::Selector::Index do
  let(:state) { state!(input) }

  describe "::call" do
    let(:index) { 100 }

    context "when called without hash" do
      subject { described_class.call(index: index) }

      it { is_expected.to be_a(described_class) }
    end

    context "when called with a hash" do
      subject { described_class.call({ index: index }) }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#call" do
    subject(:result) { selector.call(state, &:itself) }

    let(:selector) { described_class.call(index: index) }

    context "when input is not array" do
      let(:input) { "foo" }
      let(:index) { 0 }

      it_behaves_like "a fatal exception" do
        let(:attributes) do
          {
            path: be_empty,
            value: input
          }
        end
      end
    end

    context "when the index exist" do
      context "when value is nil" do
        let(:input) { [nil] }
        let(:index) { 0 }

        it { is_expected.not_to have(1).problems }
        it { is_expected.to contain(nil) }
      end

      context "when value is not nil" do
        let(:input) { [1, 2, 3] }
        let(:index) { 1 }

        it { is_expected.to contain(2) }
      end
    end

    context "when index is out of bounds" do
      let(:input) { [1, 2, 3] }
      let(:index) { 4 }

      it_behaves_like "an ignored exception" do
        let(:attributes) do
          { path: [], value: input, reason: include("4") }
        end
      end
    end

    context "when index is in bounds" do
      let(:input) { [1, 2, 3] }
      let(:index) { 1 }

      it { is_expected.to contain(2) }
    end

    context "when the array is empty" do
      let(:input) { [] }
      let(:index) { 0 }

      it_behaves_like "an ignored exception" do
        let(:attributes) do
          { path: [], value: input, reason: include("0") }
        end
      end
    end
  end
end
