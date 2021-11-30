# frozen_string_literal: true

describe Remap::Rule::Map do
  describe "::call" do
    subject { described_class.call(rule: rule!) }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    context "without fn" do
      subject { described_class.call(input_path: input_path, output_path: output_path, rule: void!).call(state) }

      let(:input_path) { [:a] }
      let(:output_path) { [:b] }
      # let(:path) { path!(input: input_path, output: output_path) }

      let(:state) { state!({ a: 1 }) }

      it { is_expected.to contain(b: 1) }
    end
  end
end
