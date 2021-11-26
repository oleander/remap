# frozen_string_literal: true

shared_examples Remap::Rule::Collection do
  subject(:rule) { described_class.call(rules: rules) }

  subject { rule.call(state) }

  let(:state) { state!(input) }

  it { is_expected.to match(output) }
end

describe Remap::Rule::Collection do
  using Remap::State::Extension

  describe "#call" do
    context "without rules" do
      it_behaves_like described_class do
        let(:rules) { [] }
        let(:input) { { foo: :bar } }
        let(:output) { have(1).problems }
      end
    end

    context "with single rule" do
      it_behaves_like described_class do
        let(:rules) { [void!] }
        let(:input) { { foo: :bar } }
        let(:output) { contain(input) }
      end
    end

    context "with two rules" do
      it_behaves_like described_class do
        let(:rules) { [void!, void!] }
        let(:input) { { foo: :bar } }
        let(:output) { contain(input) }
      end
    end
  end
end
