# frozen_string_literal: true

describe Remap::State::Extension do
  using described_class

  describe "#get" do
    subject(:result) { receiver.get(*path) }

    context "when receiver is a hash" do
      let(:receiver) { { a: 1, b: 2 } }

      context "when path is empty" do
        let(:path) { [] }

        it "raises an argument error" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context "when value exists" do
        let(:path) { %i[a] }

        it { is_expected.to eq(1) }
      end

      context "when value does not exist" do
        let(:path) { %i[c] }

        it "throws a symbol" do
          expect { subject }.to throw_symbol(:missing, [:c])
        end
      end
    end

    context "when receiver is an array" do
      let(:receiver) { [1, 2, 3] }

      context "when value exists" do
        let(:path) { [0] }

        it { is_expected.to eq(1) }
      end

      context "when value does not exist" do
        let(:path) { [4] }

        it "throws a symbol" do
          expect { subject }.to throw_symbol(:missing, [4])
        end
      end
    end

    context "when receiver is something else" do
      let(:receiver) { "string" }
      let(:path) { [0] }

      it "throws a symbol" do
        expect { subject }.to throw_symbol(:missing, [0])
      end
    end
  end

  describe "#_" do
    context "when target is valid" do
      let(:state) { defined! }

      it "does not invoke block" do
        expect { |b| state._(&b) }.not_to yield_control
      end

      it "returns target" do
        expect(state._).to eq(state)
      end
    end

    context "when target is invalid" do
      let(:state) { defined!.except(:input) }

      it "invokes block" do
        expect { |b| state._(&b) }.to yield_control
      end
    end
  end

  describe "#merged" do
    subject { left.merged(right) }

    context "when left is undefined!" do
      let(:left) { undefined!(:with_problems) }

      context "when right is undefined!" do
        let(:right) { undefined!(:with_problems) }

        it { is_expected.not_to have_key(:value) }
        it { is_expected.to have(2).problems }
      end

      context "when right is defined!" do
        let(:right) { defined!(1, :with_problems) }

        it { is_expected.to contain(right.value) }
        it { is_expected.to have(2).problems }
      end
    end

    context "when right is defined!" do
      let(:left) { defined!(:with_problems) }

      context "when right is undefined!" do
        let(:right) { undefined!(:with_problems) }

        it { is_expected.to contain(left.value) }
        it { is_expected.to have(1).problems }
      end
    end

    context "when different types" do
      let(:left) { defined!(10) }
      let(:right) { defined!(:hello) }

      it { is_expected.to have(1).problems }
      it { is_expected.not_to have_key(:value) }
    end

    context "when same type" do
      context "with same values" do
        let(:left) { defined!({ key: "value" })  }
        let(:right) { defined!({ key: "value" }) }

        it { is_expected.to include(value: { key: "value" }) }
      end

      context "when array" do
        let(:left) { defined!([1, 2]) }
        let(:right) { defined!([3, 4]) }

        it { is_expected.to include(value: contain_exactly(1, 2, 3, 4)) }
      end

      context "when hash" do
        let(:left) { defined!({ a: "A" }) }
        let(:right) { defined!({ b: "B" }) }

        it { is_expected.to contain({ a: "A", b: "B" }) }
      end
    end
  end

  describe "#merge" do
    let(:state) { undefined! }

    context "when value is undefined!" do
      subject { state.merge(key: :key) }

      it { is_expected.to have_key(:key) }
      it { is_expected.to include(path: []) }
    end

    context "when value is a state" do
      subject(:result) { state.merge(value: invalid) }

      let(:invalid) { defined! }

      it "raises an argument error" do
        expect { result }.to raise_error(ArgumentError)
      end
    end

    context "when value is not a state" do
      subject { state.merge(value: valid) }

      let(:valid) { { key: :value } }

      it { is_expected.to have_key(:value) }
      it { is_expected.to have_value(valid) }
    end
  end

  describe "#failure" do
    let(:value) { "value" }

    context "without path" do
      context "when string" do
        subject { state.failure(reason) }

        let(:state) { state!(value, path: []) }
        let(:reason) { "reason" }

        it { is_expected.to include({ base: [include({ reason: "reason" })] }) }
      end

      context "when hash" do
        subject { state.failure(reason) }

        let(:state) { state!(value, path: []) }
        let(:reason) { { key: ["reason"] } }

        it { is_expected.to include({ key: include({ reason: "reason" }) }) }
      end
    end

    context "with path" do
      context "when string" do
        subject { state.failure(reason) }

        let(:value) { "value" }
        let(:state) { state!(value, path: %i[a b]) }
        let(:reason) { "reason" }

        it { is_expected.to include({ a: { b: [include({ reason: "reason" })] } }) }
      end

      context "when hash" do
        subject { state.failure(reason) }

        let(:state) { state!(value, path: %i[a b]) }
        let(:reason) { { c: "reason" } }

        it { is_expected.to include({ a: { b: { c: [include({ reason: "reason" })] } } }) }
      end
    end
  end

  describe "#recursive_merge" do
    context "when left is undefined!" do
      let(:left) { undefined!(:with_problems) }

      context "when right is undefined!" do
        let(:right) { undefined!(:with_problems) }

        it "throws undefined! symbol" do
          expect { left.recursive_merge(right) }.to throw_symbol(:undefined)
        end
      end

      context "when right is defined!" do
        let(:right) { defined!(1, :with_problems) }

        it "returns the right hand site" do
          expect(left.recursive_merge(right)).to eq(1)
        end
      end
    end

    context "when left is defined!" do
      let(:left) { defined!(1) }

      context "when right is undefined!" do
        let(:right) { undefined! }

        it "returns the left hand site" do
          expect(left.recursive_merge(right)).to eq(1)
        end
      end
    end

    context "when left is a hash" do
      let(:left) { defined!({ a: 1, b: 2 }) }

      context "when right is a hash" do
        let(:right) { defined!({ c: 3, d: 4 }) }

        let(:output) { { a: 1, b: 2, c: 3, d: 4 } }

        it "does not invoke block" do
          expect { |b| left.recursive_merge(right, &b) }.not_to yield_control
        end

        it "returns a merged hash" do
          expect(left.recursive_merge(right)).to eq(output)
        end
      end

      context "when right is a string" do
        let(:right) { defined!("hello") }

        it "calls block with problem" do
          expect { |b| left.recursive_merge(right, &b) }.to yield_control
        end
      end

      context "when right is an array" do
        let(:right) { defined!([1, 2]) }

        it "calls block with problem" do
          expect { |b| left.recursive_merge(right, &b) }.to yield_control
        end
      end
    end

    context "when left is an array" do
      let(:left) { defined!([1, 2, 3]) }

      context "when right is a hash" do
        let(:right) { defined!({ c: 3, d: 4 }) }

        it "does invoke block" do
          expect { |b| left.recursive_merge(right, &b) }.to yield_control
        end
      end

      context "when right is a string" do
        let(:right) { defined!("hello") }

        it "calls block with problem" do
          expect { |b| left.recursive_merge(right, &b) }.to yield_control
        end
      end

      context "when right is an array" do
        let(:right) { defined!([4, 5, 6]) }

        it "does not invoke block" do
          expect { |b| left.recursive_merge(right, &b) }.not_to yield_control
        end

        it "returns a merged array" do
          expect(left.recursive_merge(right)).to eq([1, 2, 3, 4, 5, 6])
        end
      end
    end
  end

  describe "#conflicts" do
    let(:state) { defined!([100, 200]) }
    let(:key) { symbol! }

    context "when both are arrays" do
      let(:left) { [1, 2] }
      let(:right) { [3, 4] }

      it "does not invoke the block" do
        expect { |b| state.conflicts(key, left, right, &b) }.not_to yield_control
      end

      it "adds the two arrays" do
        expect(state.conflicts(key, left, right)).to contain_exactly(1, 2, 3, 4)
      end
    end

    context "when one is not an array" do
      let(:left) { { key: "value" } }
      let(:right) { [3, 4] }

      it "does invoke the block" do
        expect { |b| state.conflicts(key, left, right, &b) }.to yield_control
      end
    end
  end

  describe "#tap" do
    context "when defined!" do
      let(:state) { defined!(10) }

      it "invokes block" do
        expect { |b| state.tap(&b) }.to yield_control
      end

      it "returns self" do
        expect(state.tap { 100 }).to eq(state)
      end
    end
  end

  describe "#set" do
    let(:state) { defined! }
    let(:index) { 1 }
    let(:value) { "value" }

    context "when value is an invalid state" do
      let(:value) { defined! }

      it "sets value" do
        expect { state.set(value) }.to raise_error(ArgumentError)
      end
    end

    context "when given an index" do
      subject(:result) { state.set(value, index: index) }

      it { is_expected.to include(index: index) }
      it { is_expected.to include(element: value) }
      it { is_expected.to contain(value) }
      it { is_expected.to include(path: [index]) }
    end

    context "when given just an index" do
      subject(:result) { state.set(index: index) }

      it { is_expected.to include(index: index) }
      it { is_expected.to include(path: [index]) }
    end

    context "when given a key" do
      subject(:result) { state.set(value, key: key) }

      let(:key) { :key }

      describe "#key" do
        subject { result.execute { key } }

        it { is_expected.to contain(key) }
        it { is_expected.to include(path: [key]) }
      end

      describe "#value" do
        subject { result.execute { value } }

        it { is_expected.to contain(value) }
      end
    end

    context "when given only a value" do
      subject(:result) { state.set(value) }

      describe "#value" do
        subject { result.execute { value } }

        it { is_expected.to contain(value) }
      end
    end

    context "when state is defined!" do
      subject(:result) { state.set(**options) }

      let(:state) { defined! }
      let(:mapper) { mapper! }

      context "when given a mapper" do
        let(:options) { { mapper: mapper } }

        it "copies #value to #scope" do
          expect(result).to include(scope: state.value)
        end
      end
    end

    context "when state is undefined!" do
      subject(:result) { state.set(**options) }

      let(:state) { undefined! }
      let(:mapper) { mapper! }

      context "when given a mapper" do
        let(:options) { { mapper: mapper } }

        it "does not copy #value to #scope" do
          expect(result).not_to have_key(:scope)
        end
      end
    end
  end

  describe "#include?" do
    context "when value is defined!" do
      subject { defined!(1) }

      it { is_expected.to contain(1) }
      it { is_expected.not_to contain(2) }
    end

    context "when value is undefined!" do
      subject { undefined! }

      it { is_expected.not_to have_key(:value) }
    end
  end

  describe "#execute" do
    context "when defined!" do
      subject { state.execute { |value| value + 1 } }

      let(:state) { defined!(1) }

      it { is_expected.to contain(2) }
    end

    context "when options are avalible" do
      subject { state.execute { name } }

      let(:state) { defined!(1, name: "Linus") }

      it { is_expected.to contain("Linus") }
    end

    context "when a state is not found" do
      subject(:result) do
        state.execute do
          does_not_exist
        end
      end

      let(:state) { defined! }

      it { is_expected.to have(1).problems }
      it { is_expected.not_to have_key(:value) }
    end

    context "when #values is accessed" do
      subject(:result) do
        state.execute do
          values == input
        end
      end

      let(:state) { state! }

      it { is_expected.to contain(true) }
    end

    context "when undefined!" do
      let(:state) { undefined! }

      it "does not invoke block" do
        expect { |block| state.execute(&block) }.not_to yield_control
      end
    end

    context "when skip! is called" do
      subject do
        state.execute { skip!("This is skipped!") }
      end

      let(:value) { "value" }
      let(:state) { defined!(value, path: [:key1]) }
      let(:problems) { [{ path: [:key1], reason: "This is skipped!", value: value }] }

      it { is_expected.to include(problems: problems) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when undefined! is returned" do
      subject do
        state.execute { undefined! }
      end

      let(:state) { defined! }

      it { is_expected.to have(1).problems }
      it { is_expected.not_to have_key(:value) }
    end

    context "when #get is used" do
      context "when value exists" do
        subject do
          state.execute do
            value.get(:a, :b)
          end
        end

        let(:value) { { a: { b: "value" } } }
        let(:state) { defined!(value) }

        it { is_expected.to contain("value") }
      end

      context "when value does not exists" do
        subject do
          state.execute do
            value.get(:a, :x)
          end
        end

        let(:value) { { a: { b: "value" } } }
        let(:state) { defined!(value) }
        let(:problems) { [{ path: %i[a x], reason: be_a(String), value: value }] }

        it { is_expected.to include(problems: problems) }
      end
    end

    context "when KeyError is raised" do
      subject do
        state.execute do
          input.fetch(:does_not_exist)
        end
      end

      let(:value) { { key: "value" } }
      let(:state) { defined!(value) }

      it { is_expected.to have(1).problems }
      it { is_expected.not_to have_key(:value) }
    end

    context "when IndexError is raised" do
      subject do
        state.execute do
          value.fetch(10)
        end
      end

      let(:value) { [1, 2, 3] }
      let(:state) { defined!(value) }

      it { is_expected.to have(1).problems }
      it { is_expected.not_to have_key(:value) }
    end
  end

  describe "#fmap" do
    context "when value is defined!" do
      let(:state) { defined!(1) }

      it "invokes block with value" do
        expect(state.fmap { |v| v + 1 }).to contain(2)
      end
    end

    context "when options are passed" do
      subject do
        state.fmap(key: key) do |&error|
          error["message"]
        end
      end

      let(:key) { :key }
      let(:value) { "value" }
      let(:state) { defined!(value) }
      let(:problems) { [{ path: [key], reason: "message", value: value }] }

      it { is_expected.to include(problems: problems) }
    end

    context "when value not defined!" do
      let(:state) { undefined! }

      it "invokes block with value" do
        expect { |block| state.fmap(&block) }.not_to yield_control
      end
    end

    context "when error block is invoked" do
      context "without pre-existing path" do
        subject do
          state.fmap do |_value, &error|
            error[reason]
          end
        end

        let(:state) { defined! }
        let(:reason) { "reason" }

        it { is_expected.not_to have_key(:value) }
        it { is_expected.to have(1).problems }
      end

      context "with pre-existing path" do
        context "without key argument" do
          subject do
            state.fmap do |_value, &error|
              error[reason]
            end
          end

          let(:state) { defined!(1, path: [:key]) }
          let(:reason) { "reason" }
          let(:problems) { [{ path: [:key], reason: reason, value: 1 }] }

          it { is_expected.to include(problems: problems) }
        end

        context "with key argument" do
          subject do
            state.fmap(key: :key2) do |_value, &error|
              error[reason]
            end
          end

          let(:state) { defined!(1, path: [:key1]) }
          let(:reason) { "reason" }
          let(:problems) { [{ path: %i[key1 key2], reason: reason, value: 1 }] }

          it { is_expected.to include(problems: problems) }
        end
      end
    end
  end

  describe "#bind" do
    context "when value is defined!" do
      let(:state) { defined!(1) }

      it "invokes block with value" do
        expect(state.bind { |v, s| s.set(v + 1) }).to contain(2)
      end
    end

    context "when value not defined!" do
      let(:state) { undefined! }

      it "invokes block with value" do
        expect { |block| state.bind(&block) }.not_to yield_control
      end

      it "returns itself" do
        expect(state.bind { raise "nope" }).to eq(state)
      end
    end

    context "when options are passed" do
      subject do
        state.bind(key: key) do |_value, _state, &error|
          error["error"]
        end
      end

      let(:key) { :key }
      let(:value) { "value" }
      let(:state) { defined!(value) }
      let(:problems) { [{ path: [key], reason: "error", value: value }] }

      it { is_expected.to include(problems: problems) }
    end

    context "when error block is invoked" do
      subject do
        state.bind do |&error|
          error[reason]
        end
      end

      let(:state) { defined! }
      let(:reason) { "reason" }

      it { is_expected.not_to have_key(:value) }
      it { is_expected.to have(1).problems }
    end
  end

  describe "#problem" do
    subject { state.problem(reason) }

    let(:path) { [:key1] }
    let(:reason) { "reason" }
    let(:value) { "value" }

    context "when value is defined" do
      let(:state) { defined!(value, path: path) }
      let(:problems) { [{ path: path, value: value, reason: reason }] }

      it { is_expected.to include(problems: problems) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when value is undefined" do
      let(:state) { undefined!(path: path) }
      let(:problems) { [{ path: path, reason: reason }] }

      it { is_expected.to include(problems: problems) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when path is defined" do
      let(:path) { %i[key1 key2] }
      let(:state) { defined!(value, path: path) }
      let(:problems) { [{ path: path, value: value, reason: reason }] }

      it { is_expected.to include(problems: problems) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when path is undefined" do
      let(:state) { defined!(value, path: []) }
      let(:problems) { [{ value: value, reason: reason }] }

      it { is_expected.to include(problems: problems) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when problems already exists" do
      let(:init_problems) { [{ path: [:key1], value: value, reason: "reason1" }] }
      let(:state) { defined!(value, path: [:key1], problems: init_problems) }
      let(:problems) { init_problems + [{ path: [:key1], value: value, reason: reason }] }

      it { is_expected.to include(problems: problems) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when problems does not exist" do
      let(:state) { defined!(value, path: [:key1], problems: []) }
      let(:problems) { [{ path: [:key1], value: value, reason: reason }] }

      it { is_expected.to include(problems: problems) }
      it { is_expected.not_to have_key(:value) }
    end
  end

  describe "#inspect" do
    subject { defined!.inspect }

    it { is_expected.to be_a(String) }
    it { is_expected.to include("#<State") }
  end
end
