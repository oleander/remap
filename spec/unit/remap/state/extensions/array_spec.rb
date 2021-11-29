# frozen_string_literal: true

describe Remap::State::Extensions::Array do
  using described_class

  describe "#get" do
    subject(:result) { receiver.get(*path) }

    context "when path is empty" do
      let(:path) { [] }
      let(:receiver) { ["value"] }

      it { is_expected.to eq(["value"]) }
    end

    context "when empty" do
      let(:receiver) { [] }
      let(:path) { [0] }

      it "throws a symbol" do
        expect { result }.to throw_symbol(:missing, [0])
      end
    end

    context "when not empty" do
      context "when value exists" do
        let(:receiver) { [{ a: "value" }] }
        let(:path) { [0, :a] }

        it { is_expected.to eq("value") }
      end

      context "when value does not exist" do
        let(:receiver) { ["value"] }
        let(:path) { [0, 1] }

        it "throws a symbol" do
          expect { result }.to throw_symbol(:missing, [0, 1])
        end
      end
    end
  end

  describe "#hide" do
    subject { target.hide(value) }

    let(:value) { value! }

    context "when target is empty" do
      let(:target) { [] }

      it { is_expected.to eq(value) }
    end

    context "when target is not empty" do
      let(:target) { %i[a b] }

      it { is_expected.to eq({ a: { b: value } }) }
    end
  end
end
