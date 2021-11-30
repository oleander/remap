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
end
