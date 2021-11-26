# frozen_string_literal: true

describe Remap::Mapper do
  describe "::|" do
    subject(:output) { left | right }

    let(:left) do
      Class.new(Remap::Base) do
        define { map :b }
      end
    end

    context "when right side is a mapper" do
      let(:right) do
        Class.new(Remap::Base) do
          define { map :a }
        end
      end

      it { is_expected.to be_a(described_class) }
    end

    context "when right side isn't a mapper" do
      let(:right) { Object.new }

      it "raises an argument error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "::&" do
    subject(:output) { left & right }

    let(:left) do
      Class.new(Remap::Base) do
        define { map :b }
      end
    end

    context "when right side is a mapper" do
      let(:right) do
        Class.new(Remap::Base) do
          define { map :a }
        end
      end

      it { is_expected.to be_a(described_class) }
    end

    context "when right side isn't a mapper" do
      let(:right) { Object.new }

      it "raises an argument error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "::^" do
    subject(:output) { left ^ right }

    let(:left) do
      Class.new(Remap::Base) do
        define { map :b }
      end
    end

    context "when right side is a mapper" do
      let(:right) do
        Class.new(Remap::Base) do
          define { map :a }
        end
      end

      it { is_expected.to be_a(described_class) }
    end

    context "when right side isn't a mapper" do
      let(:right) { Object.new }

      it "raises an argument error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end
end
