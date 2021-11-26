# frozen_string_literal: true

describe Remap::Constructor::None do
  shared_examples described_class do
    subject(:constructor) { described_class.new(target: target, method: method, strategy: strategy) }

    let(:method) { Remap::Nothing }
    let(:strategy) { Remap::Nothing }
    let(:target) { Remap::Nothing }
    let(:value) { value! }
    let(:state) { state!(value) }

    it "returns the input state" do
      expect(constructor.call(state)).to eq(state)
    end
  end

  describe "#call" do
    context "when method is defined" do
      it_behaves_like described_class do
        let(:method) { :hello }
      end
    end

    context "when method is not defined" do
      it_behaves_like described_class do
        let(:method) { Remap::Nothing }
      end
    end

    context "when strategy is defined" do
      it_behaves_like described_class do
        let(:method) { :keyword }
      end
    end

    context "when strategy is undefined" do
      it_behaves_like described_class do
        let(:method) { Remap::Nothing }
      end
    end
  end
end
