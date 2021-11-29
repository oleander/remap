# frozen_string_literal: true

describe Remap::State::Extensions::Enumerable do
  using described_class

  describe "#get" do
    context "when receiver is a hash" do
      subject(:result) { receiver.get(*path) }

      context "when path is empty" do
        let(:path) { [] }
        let(:receiver) { { key: "value" } }

        it { is_expected.to eq(receiver) }
      end

      context "when receiver is empty" do
        let(:receiver) { {} }
        let(:path) { [0] }

        it "throws a symbol" do
          expect { result }.to throw_symbol(:missing, path)
        end
      end

      context "when path is not empty" do
        context "when value exists in receiver" do
          let(:receiver) { { a: ["value"] } }
          let(:path) { [:a, 0] }

          it { is_expected.to eq("value") }
        end

        context "when value does not exist" do
          let(:receiver) { { a: { b: "value" } } }
          let(:path) { [:a, 0] }

          it "throws a symbol" do
            expect { result }.to throw_symbol(:missing, path)
          end
        end
      end
    end

    context "when receiver is an array" do
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
