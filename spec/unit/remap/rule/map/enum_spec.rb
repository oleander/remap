# frozen_string_literal: true

describe Remap::Rule::Map::Enum do
  shared_examples described_class do
    subject { enum[lookup] }

    it { is_expected.to match(output) }
  end

  let(:state) { build(:null) }

  describe "::call" do
    context "without block" do
      it "raises an ArgumentError" do
        expect { described_class.call }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#get" do
    subject(:enum) do
      described_class.call do
        value "ID"
      end
    end

    let(:context) { context! }

    context "when input is missing" do
      it "raises an error" do
        expect { enum.get("NOPE") }.to raise_error(Remap::Error)
      end
    end

    context "when input is not missing" do
      it "returns value" do
        expect(enum.get("ID")).to eq("ID")
      end
    end
  end
end
