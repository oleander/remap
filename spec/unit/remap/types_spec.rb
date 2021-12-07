# frozen_string_literal: true

describe Remap::Types do
  describe described_class::State do
    context "given valid input" do
      it "does not invoke block" do
        expect { |b| described_class.call(state!, &b) }.not_to yield_control
      end
    end

    context "given invalid input" do
      it "does invoke block" do
        expect { |b| described_class.call({}, &b) }.to yield_control
      end
    end

    it "does not raise an error" do
      expect { described_class.call(state!) }.not_to raise_error
    end
  end

  describe "::call" do
    describe described_class::Nothing do
      context "when undefined" do
        subject { described_class.call(input) }

        let(:input) { Remap::Nothing }
        let(:output) { input }

        it { is_expected.to eq(output) }
      end
    end
  end
end
