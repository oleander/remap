# frozen_string_literal: true

describe Remap::Compiler do
  subject(:output) { rule.call(state) }

  let(:rule)  { described_class.call(&block) }
  let(:state) { state!(input)                }

  describe "#each" do
    let(:input) { [{ a: 1 }, { a: 2 }] }

    context "with block" do
      let(:block) { -> * { each { map :a } } }

      it { is_expected.to contain([1, 2]) }
    end

    context "without block" do
      let(:block) { -> * { each } }

      it "raises an argument error" do
        expect { rule.call(state) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#wrap" do
    let(:input) { { a: 100 } }

    context "with invalid type" do
      let(:block) { -> * { wrap(:does_not_exist) { map :a } } }

      it "raises an argument error" do
        expect { rule.call(state) }.to raise_error(ArgumentError)
      end
    end

    context "with block" do
      let(:input) { { a: 100 }                       }
      let(:block) { -> * { wrap(:array) { map :a } } }

      it { is_expected.to contain([100]) }
    end

    context "without block" do
      let(:input) { { a: 100 } }
      let(:block) { -> * { wrap(:array) } }

      it "raises an argument error" do
        expect { rule.call(state) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#map" do
    context "without block" do
      let(:input) { { a: { b: 100 } } }
      let(:block) { -> * { map :a, :b } }

      it { is_expected.to contain(100) }
    end

    context "with block" do
      let(:input) { { a: { b: 100 } } }
      let(:block) { -> * { map(:a) { map(:b) } } }

      it { is_expected.to contain(100) }
    end
  end

  describe "#to" do
    context "without block" do
      let(:input) { value! }
      let(:block) { -> * { to :a, :b } }

      it { is_expected.to contain({ a: { b: input } }) }
    end

    context "with block" do
      let(:input) { value! }
      let(:block) { -> * { to(:a) { to(:b) } } }

      it { is_expected.to contain({ a: { b: input } }) }
    end
  end

  describe "#all" do
    let(:block) { -> * { map [all, :a] } }

    context "when non-empty" do
      let(:input) { [{ a: 1 }, { a: 2 }] }

      it { is_expected.to contain([1, 2]) }
    end
  end

  describe "#first" do
    let(:block) { -> * { map [first] } }

    context "when non-empty" do
      let(:input) { array! }

      it { is_expected.to contain(input.first) }
    end
  end

  describe "#last" do
    let(:block) { -> * { map [last] } }

    context "when non-empty" do
      let(:input) { array! }

      it { is_expected.to contain(input.last) }
    end
  end

  describe "#at(index)" do
    let(:input) { array! }

    context "when inside range" do
      let(:block) { -> * { map [at(1)] } }

      it { is_expected.to contain(input[1]) }
    end

    context "when outside range" do
      let(:block) { -> * { map? [at(100)] } }

      it { is_expected.to have(1).problems }
    end

    context "when a non-int is passed" do
      let(:block) { -> * { map [at(:not_an_index)] } }

      it "raises an argument error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#embed" do
    context "with a non-mapper as argument" do
      let(:block) { -> * { embed Object.new } }
      let(:input) { { a: 1 } }

      it "raises an argument error" do
        expect { rule.call(state) }.to raise_error(ArgumentError)
      end
    end

    context "with mapper as argument" do
      let(:mapper) do
        Class.new(Remap::Base) do
          define { map :a }
        end
      end

      let(:block) do |this: self|
        -> * { embed this.mapper }
      end

      let(:input) { { a: 1 } }

      it { is_expected.to contain(1) }
    end
  end

  describe "#set" do
    let(:input) { {} }

    context "when using #value" do
      let(:block) { -> * { set :a, :b, to: value("a value") } }

      it { is_expected.to contain({ a: { b: "a value" } }) }
    end

    context "given an invalid path" do
      let(:block) { -> * { set :a, to: nil } }

      it "raises an argument error" do
        expect { rule.call(state) }.to raise_error(ArgumentError)
      end
    end

    context "given using #option" do
      let(:id) { symbol! }
      let(:state) { state!(options: { id: id }) }

      context "when value exists" do
        let(:block) { -> * { set :a, :b, to: option(:id) } }

        it { is_expected.to contain({ a: { b: id } }) }
      end

      context "when value does not exist" do
        let(:block) { -> * { set :a, :b, to: option(:does_not_exist) } }

        it "raises an argument error" do
          expect { rule.call(state) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
