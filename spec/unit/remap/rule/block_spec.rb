# frozen_string_literal: true

describe Remap::Rule::Block do
  using Remap::State::Extension

  shared_examples described_class do
    subject(:rule) { described_class.call(rules: rules, backtrace: caller) }

    subject { rule.call(state, &error) }

    let(:state) { state!(input) }

    it { is_expected.to match(output) }
  end

  describe "#call" do
    context "without rules" do
      subject(:rule) { described_class.call(rules: rules, backtrace: caller) }

      let(:rules) { [] }
      let(:input) { { foo: :bar } }
      let(:state) { state!(input) }

      it "throws a notice symbol" do
        expect(rule.call(state, &error)).not_to have_key(:value)
      end
    end

    context "with single rule" do
      it_behaves_like described_class do
        let(:rules) { [void!] }
        let(:input)  { { foo: :bar }  }
        let(:output) { contain(input) }
      end
    end

    context "with two rules" do
      it_behaves_like described_class do
        let(:rules) { [void!, void!] }
        let(:input)  { { foo: :bar }  }
        let(:output) { contain(input) }
      end
    end
  end
end
