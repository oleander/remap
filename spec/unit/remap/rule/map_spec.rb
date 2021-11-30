# frozen_string_literal: true

describe Remap::Rule::Map do
  describe "::call" do
    subject { described_class.call(rule: rule!, path: path!) }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    context "without fn" do
      subject { described_class.call(path: path, rule: void!).call(state) }

      let(:path) { path!([:a], [:b]) }
      let(:state) { state!({ a: 1 }) }

      it { is_expected.to contain(b: 1) }
    end
  end
end
