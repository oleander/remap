# frozen_string_literal: true

describe Remap::Compiler do
  using Remap::State::Extension

  subject(:output) { rule.call(state, &error) }

  let(:rule)  { described_class.call(&block) }
  let(:input) { value! }
  let(:state) { state!(input) }

  describe "#each" do
    let(:input) { [{ a: 1 }, { a: 2 }] }

    context "with block" do
      let(:block) { -> * { each { map :a } } }

      it { is_expected.to contain([1, 2]) }
    end

    context "without block" do
      let(:block) { -> { each } }

      it "raises an argument error" do
        expect { output }.to raise_error(ArgumentError)
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
      let(:block) { -> { wrap(:array) } }

      it "raises an argument error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#get" do
    subject { rule.call(state, &error) }

    let(:rule) { described_class.call(&context) }

    context "when state is undefined" do
      let(:state) { undefined! }

      context "when rule is nested" do
        let(:context) do
          -> do
            get :person do
              get :name
            end
          end
        end

        it { is_expected.to eq(state) }
      end

      context "when rule not nested" do
        let(:context) do
          -> do
            get :person
          end
        end

        it { is_expected.to eq(state) }
      end
    end

    context "when rule is nested" do
      let(:context) do
        -> do
          get :person do
            get :name
          end
        end
      end

      context "when path is a match" do
        let(:input) { { person: { name: "John" } } }

        it { is_expected.to contain(input) }
      end

      context "when path is not a match" do
        let(:input) { { person: { mismatch: "John" } } }

        it_behaves_like "an ignored exception" do
          subject(:result) do
            rule.call(state)
          end

          let(:attributes) do
            { value: { mismatch: "John" }, path: [:person], reason: include("name") }
          end
        end
      end
    end

    context "when rule not nested" do
      let(:context) do
        -> do
          get :name
        end
      end

      context "when path is a match" do
        let(:input) { { name: "John" } }

        it { is_expected.to contain(input) }
      end

      context "when path is not a match" do
        let(:input) { { mismatch: "John" } }

        it_behaves_like "an ignored exception" do
          subject(:result) do
            rule.call(state)
          end

          let(:attributes) do
            { value: { mismatch: "John" }, path: [], reason: include("name") }
          end
        end
      end
    end
  end

  describe "#get?" do
    subject { rule.call(state, &error) }

    let(:rule) { described_class.call(&context) }

    context "when state is undefined" do
      let(:state) { undefined! }

      context "when rule is nested" do
        let(:context) do
          -> do
            get? :person do
              get :name
            end
          end
        end

        it { is_expected.to eq(state) }
      end

      context "when rule not nested" do
        let(:context) do
          -> do
            get? :person
          end
        end

        it { is_expected.to eq(state) }
      end
    end

    context "when rule is nested" do
      let(:context) do
        -> do
          get? :person do
            get? :name
          end
        end
      end

      context "when path is a match" do
        let(:input) { { person: { name: "John" } } }

        it { is_expected.to contain(input) }
      end

      context "when path is not a match" do
        let(:input) { { person: { mismatch: "John" } } }

        it "does not yields a failure" do
          expect { |error| rule.call(state, &error) }.not_to yield_control
        end

        it { is_expected.not_to have_key(:value) }
        its([:notices]) { is_expected.to have(1).item }
      end
    end

    context "when rule not nested" do
      let(:context) do
        -> do
          get? :name
        end
      end

      context "when path is a match" do
        let(:input) { { name: "John" } }

        it { is_expected.to contain(input) }
      end

      context "when path is not a match" do
        let(:input) { { mismatch: "John" } }

        it "does not yield a failure" do
          expect { |error| rule.call(state, &error) }.not_to yield_control
        end

        it { is_expected.not_to have_key(:value) }
        its([:notices]) { is_expected.to have(1).item }
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

  describe "#map?" do
    subject { rule.call(state, &error) }

    let(:rule) { described_class.call(&context) }

    context "when state is undefined" do
      let(:state) { undefined! }

      context "when rule is nested" do
        let(:context) do
          -> do
            map? :person do
              map :name
            end
          end
        end

        it { is_expected.to eq(state) }
      end

      context "when rule not nested" do
        let(:context) do
          -> do
            map? :person
          end
        end

        it { is_expected.to eq(state) }
      end
    end

    context "when rule is nested" do
      let(:context) do
        -> do
          map? :person do
            map? :name
          end
        end
      end

      context "when path is a match" do
        let(:input) { { person: { name: "John" } } }

        it { is_expected.to contain("John") }
      end

      context "when path is not a match" do
        let(:input) { { person: { mismatch: "John" } } }

        it "does not yields a failure" do
          expect { |error| rule.call(state, &error) }.not_to yield_control
        end

        it { is_expected.not_to have_key(:value) }
        its([:notices]) { is_expected.to have(1).item }
      end
    end

    context "when rule not nested" do
      let(:context) do
        -> do
          map? :name
        end
      end

      context "when path is a match" do
        let(:input) { { name: "John" } }

        it { is_expected.to contain("John") }
      end

      context "when path is not a match" do
        let(:input) { { mismatch: "John" } }

        it "does not yield a failure" do
          expect { |error| rule.call(state, &error) }.not_to yield_control
        end

        it { is_expected.not_to have_key(:value) }
        its([:notices]) { is_expected.to have(1).item }
      end
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

  describe "#to?" do
    subject { rule.call(state, &error) }

    let(:rule) { described_class.call(&context) }

    context "when state is undefined" do
      let(:state) { undefined! }

      context "when rule is nested" do
        let(:context) do
          -> do
            to? :person do
              to :name
            end
          end
        end

        it { is_expected.to eq(state) }
      end

      context "when rule not nested" do
        let(:context) do
          -> do
            to? :person
          end
        end

        it { is_expected.to eq(state) }
      end
    end

    context "when rule is nested" do
      let(:context) do
        -> do
          to? map: :person do
            to? map: :name
          end
        end
      end

      context "when path is a match" do
        let(:input) { { person: { name: "John" } } }

        it { is_expected.to contain("John") }
      end

      context "when path is not a match" do
        let(:input) { { person: { mismatch: "John" } } }

        it "does not yields a failure" do
          expect { |error| rule.call(state, &error) }.not_to yield_control
        end

        it { is_expected.not_to have_key(:value) }
        its([:notices]) { is_expected.to have(1).item }
      end
    end

    context "when rule not nested" do
      let(:context) do
        -> do
          to? map: :name
        end
      end

      context "when path is a match" do
        let(:input) { { name: "John" } }

        it { is_expected.to contain("John") }
      end

      context "when path is not a match" do
        let(:input) { { mismatch: "John" } }

        it "does not yield a failure" do
          expect { |error| rule.call(state, &error) }.not_to yield_control
        end

        it { is_expected.not_to have_key(:value) }
        its([:notices]) { is_expected.to have(1).item }
      end
    end
  end

  describe "#all" do
    let(:block) { -> * { map [all, :a] } }

    context "when non-empty" do
      let(:input) { [{ a: 1 }, { a: 2 }] }

      it { is_expected.to contain([1, 2]) }
    end

    context "given a block" do
      let(:block) do
        -> do
          all do
            # NOP
          end
        end
      end

      it "raises an error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#first" do
    let(:block) { -> { map [first] } }

    context "when non-empty" do
      let(:input) { array! }

      it { is_expected.to contain(input.first) }
    end

    context "given a block" do
      let(:block) do
        -> do
          first do
            # NOP
          end
        end
      end

      it "raises an error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#last" do
    let(:block) { -> { map [last] } }

    context "when non-empty" do
      let(:input) { array! }

      it { is_expected.to contain(input.last) }
    end

    context "given a block" do
      let(:block) do
        -> do
          last do
            # NOP
          end
        end
      end

      it "raises an error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#at(index)" do
    let(:input) { array! }

    context "when inside range" do
      let(:block) { -> { map [at(1)] } }

      it { is_expected.to contain(input[1]) }
    end

    context "when outside range" do
      let(:block) { -> { map? [at(100)] } }

      its([:notices]) { is_expected.to have(1).items }
    end

    context "when a non-int is passed" do
      let(:block) { -> { map [at(:not_an_index)] } }

      it "raises an argument error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end

    context "given a block" do
      let(:block) do
        -> do
          at(10) do
            # NOP
          end
        end
      end

      it "raises an error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#embed" do
    context "given a block" do
      let(:mapper) { mapper! }

      let(:block) do |context: self|
        -> do
          embed(context.mapper) do
            # NOP
          end
        end
      end

      it "raises an error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end

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

    context "given a block" do
      let(:block) do
        -> do
          set(to: value("a value")) do
            # NOP
          end
        end
      end

      it "raises an error" do
        expect { output }.to raise_error(ArgumentError)
      end
    end

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
      let(:id)    { symbol! }
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
