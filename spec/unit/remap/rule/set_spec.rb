# frozen_string_literal: true

describe Remap::Rule::Set do
  describe "::call" do
    subject(:rule) { described_class.call(path: path, value: static) }

    let(:path) { path! }

    context "given option" do
      let(:static) { build(Remap::Static::Option) }

      it { is_expected.to be_a(described_class) }
    end

    context "given value" do
      let(:static) { build(Remap::Static::Fixed) }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#call" do
    subject { rule.call(state) }

    let(:key) { symbol! }
    let(:rule) { described_class.call(path: path!(output: [key]), value: static) }
    let(:value) { value! }

    context "given option" do
      let(:id) { symbol! }
      let(:static) { build("static/option", name: id) }

      context "when state includes the option" do
        let(:state) { build(:element, options: { id => value }) }

        it { is_expected.to contain({ key => value }) }
      end

      context "when the state does not include the option" do
        let(:state) { state! }

        it "raises an argument error" do
          expect { rule.call(state) }.to raise_error(ArgumentError)
        end
      end
    end

    context "given value" do
      let(:fixed) { value! }
      let(:state) { state! }
      let(:static) { build("static/fixed", value: fixed) }

      it { is_expected.to contain(key => fixed) }
    end
  end
end
