# frozen_string_literal: true

describe Remap::Rule::Wrap do
  describe "::call" do
    subject(:result) { described_class.call(type: type, rule: void!) }

    context "when type is not :array" do
      let(:type) { :string }

      it "raises an error" do
        expect { result }.to raise_error(Dry::Struct::Error)
      end
    end

    context "when type is array" do
      let(:type) { :array }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#call" do
    subject { wrap.call(state, &error) }

    let(:wrap)  { described_class.new(type: type, rule: void!) }
    let(:state) { state!(input) }

    context "when type is :array" do
      let(:type) { :array }

      context "when input is undefined" do
        let(:state) { undefined! }

        it { is_expected.to eq(state) }
      end

      context "when input is an array" do
        let(:input) { [1, 2, 3] }

        it { is_expected.to contain(input) }
      end

      context "when input is not array" do
        let(:input) { :not_an_array }

        it { is_expected.to contain([input]) }
      end
    end
  end
end
