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

  describe described_class::Problem do
    let(:valid) { { reason: "reason", value: "a value", path: [:a, :b] } }

    it "does not invoke block" do
      expect { |b| described_class.call(valid, &b) }.not_to yield_control
    end

    context "when path is empty" do
      let(:input) { valid.merge(path: []) }

      it "invokes block" do
        expect { |b| described_class.call(input, &b) }.to yield_control
      end
    end

    context "when path is missing" do
      let(:input) { valid.except(:path) }

      it "does not invokes block" do
        expect { |b| described_class.call(input, &b) }.not_to yield_control
      end
    end

    context "when reason is empty" do
      let(:input) { valid.merge(reason: "") }

      it "invokes block" do
        expect { |b| described_class.call(input, &b) }.to yield_control
      end
    end

    context "when value is missing" do
      let(:input) { valid.except(:value) }

      it "does not invokes block" do
        expect { |b| described_class.call(input, &b) }.not_to yield_control
      end
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
