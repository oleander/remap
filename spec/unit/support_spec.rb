# frozen_string_literal: true

describe Support do
  include described_class
  extend described_class

  using Remap::State::Extension

  describe "#static!" do
    subject(:rule) { static!(value) }

    let(:value) { value! }
    let(:state) { state! }

    it "returns its input value" do
      expect(rule.call(state)).to contain(value)
    end
  end

  describe "#path!" do
    subject(:result) do
      path.call(state) do |state|
        state.fmap do |value|
          value.class
        end
      end
    end

    let(:value) { { a: "value" } }
    let(:state) { state!(value) }

    let(:path) { path!(input: [:a], output: [:b]) }

    it "returns its input value" do
      expect(result).to contain(b: String)
    end
  end
end
