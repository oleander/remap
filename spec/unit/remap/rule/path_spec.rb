# frozen_string_literal: true

describe Remap::Rule::Path do
  using Remap::State::Extension

  shared_context described_class do
    subject { path.call(state, &:itself) }

    let(:path) { described_class.call(map: map, to: to) }
    let(:state) { state!(input) }
  end

  context "when path is not found" do
    context "when index is a miss" do
      it_behaves_like described_class do
        let(:map) { [:a, index!(1)] }
        let(:input) { { a: ["A"] } }
        let(:to) { [:c] }

        it { is_expected.to include(problems: { a: { 1 => be_a(Array) } }) }
      end
    end

    context "when key is a miss" do
      it_behaves_like described_class do
        let(:map) { %i[a miss] }
        let(:input) { { a: ["A"] } }
        let(:to) { [:c] }

        it { is_expected.to include(problems: include(a: { miss: be_a(Array) })) }
      end
    end

    context "when #all selector does not match an array" do
      it_behaves_like described_class do
        let(:map) { [:a, all!] }
        let(:input) { { a: "NOT-AN-ARRAY" } }
        let(:to) { [:c] }

        it { is_expected.to include(problems: include(a: { "*" => be_a(Array) })) }
      end
    end

    context "when #first selector does not match an array" do
      it_behaves_like described_class do
        let(:map) { [:a, first!] }
        let(:input) { { a: "NOT-AN-ARRAY" } }
        let(:to) { [:c] }

        it { is_expected.to include(problems: include(a: { 0 => be_a(Array) })) }
      end
    end
  end

  context "when path is found" do
    context "when map & to is empty" do
      it_behaves_like described_class do
        let(:map) { [] }
        let(:to) { [] }
        let(:input) { { cars: %i[car0 car1] } }

        it_behaves_like "a success" do
          let(:expected) { input }
        end
      end
    end

    context "given indexes" do
      it_behaves_like described_class do
        let(:map) { [index!(1)] }
        let(:input) { %w[A B] }
        let(:to) { [:c] }

        it { is_expected.to contain(c: "B") }
      end
    end

    context "given symbols" do
      it_behaves_like described_class do
        let(:map) { [:a] }
        let(:to) { [:b] }
        let(:input) { { a: "A" } }

        it { is_expected.to contain(b: "A") }
      end
    end

    context "given strings" do
      it_behaves_like described_class do
        let(:map) { ["a"] }
        let(:to) { ["b"] }
        let(:input) { { "a" => "A" } }

        it { is_expected.to contain("b" => "A") }
      end
    end

    context "given #all selector" do
      it_behaves_like described_class do
        let(:map) { [all!, :a] }
        let(:to) { [:b] }
        let(:input) { [{ a: "A" }, { a: "B" }] }

        it { is_expected.to contain(b: %w[A B]) }
      end
    end
  end
end
