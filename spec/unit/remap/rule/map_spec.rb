# frozen_string_literal: true

describe Remap::Rule::Map do
  describe "::call" do
    subject { described_class.call(rule: rule!, path: path!) }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    subject { rule.call(state, &error) }

    let(:rule)  { described_class.call(path: path, rule: void!) }
    let(:state) { state!({ a: 1 })                              }

    context "without fn" do
      let(:path) { path!([:a], [:b]) }

      it { is_expected.to contain(b: 1) }
    end

    context "when input path is not found" do
      let(:path) { path!([:X], [:b]) }

      it { is_expected.to include(notices: be_present) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when pending is used" do
      let(:path) { path!([:a]) }

      before do
        rule.pending("this is a message")
      end

      it { is_expected.to include(notices: be_present) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when #if is used" do
      let(:path) { path!([]) }

      before do
        rule.if(&:even?)
      end

      context "when true" do
        let(:state) { state!(10) }

        it { is_expected.to contain(10) }
      end

      context "when false" do
        let(:state) { state!(5) }

        before do
          rule.if(&:even?)
        end

        it { is_expected.not_to have_key(:value) }
      end
    end

    context "when #if_not is used" do
      let(:path) { path!([]) }

      context "when passing" do
        let(:state) { state!(10) }

        before do
          rule.if_not(&:odd?)
        end

        it { is_expected.to contain(10) }
      end

      context "when failing" do
        let(:state) { state!(15) }

        before do
          rule.if_not(&:odd?)
        end

        it { is_expected.not_to have_key(:value) }
      end
    end
  end
end
