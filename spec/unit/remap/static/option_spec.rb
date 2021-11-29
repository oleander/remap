# frozen_string_literal: true

describe Remap::Static::Option do
  describe "::call" do
    subject { described_class.call(name: symbol!) }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    subject(:option) { described_class.call(name: id).call(state) }

    let(:id) { :id }

    context "when state includes the option" do
      let(:state) { state!(id: id) }

      it { is_expected.to contain(id) }
    end

    context "when the state does not include the option" do
      let(:state) { state! }

      it "raises an argument error" do
        expect { option }.to raise_error(ArgumentError)
      end
    end
  end
end
