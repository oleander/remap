# frozen_string_literal: true

describe Remap::Static do
  describe "::call" do
    context "given a name" do
      subject { described_class.call(name: symbol!) }

      it { is_expected.to be_a(described_class::Option) }
    end

    context "given a value" do
      subject { described_class.call(value: value!) }

      it { is_expected.to be_a(described_class::Fixed) }
    end
  end
end
