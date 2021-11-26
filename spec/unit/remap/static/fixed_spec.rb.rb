# frozen_string_literal: true

describe Remap::Static::Fixed do
  let(:value) { value! }

  describe "::call" do
    subject { described_class.call(value: value) }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    subject { described_class.call(value: value).call(state!) }

    it { is_expected.to contain(value) }
  end
end
