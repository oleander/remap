# frozen_string_literal: true

describe Remap::State::Extensions::Array do
  using described_class

  describe "#get" do
    subject(:result) { receiver.get(*path) }

    context "when empty" do
      let(:receiver) { [] }
      let(:path) { [0] }

      it "throws a symbol" do
        expect { result }.to throw_symbol(:missing, [0])
      end
    end

    context "when not empty" do
      let(:receiver) { [1, 2, 3, 4] }

      context "when value exists" do
        let(:path) { [0] }

        it { is_expected.to eq(1) }
      end

      context "when value does not exist" do
        let(:path) { [4] }

        it "throws a symbol" do
          expect { result }.to throw_symbol(:missing, [4])
        end
      end
    end
  end
end
