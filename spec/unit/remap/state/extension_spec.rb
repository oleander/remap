# frozen_string_literal: true

describe Remap::State::Extension do
  using Remap::State::Extensions::Enumerable
  using described_class

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

  describe "#notice" do
    context "when state is undefined" do
      subject { state.notice("%s", "a value") }

      let(:state) { undefined! }

      it { is_expected.to be_a(Remap::Notice) }
    end

    context "when state is defined" do
      subject { state.notice("%s", "a value") }

      let(:state) { defined! }

      it { is_expected.to be_a(Remap::Notice) }
    end
  end

  describe "#fatal" do
    let(:state) { defined! }

    it "throws a symbol" do
      expect do
        state.fatal!("%s",
                     "a value")
      end.to throw_symbol(:fatal, be_kind_of(Remap::Notice))
    end
  end

  describe "#notice!" do
    let(:state) { defined! }

    it "throws a symbol" do
      expect do
        state.notice!("%s",
                      "a value")
      end.to throw_symbol(:notice, be_kind_of(Remap::Notice))
    end
  end

  describe "#ignore!" do
    let(:state) { defined! }

    it "throws a symbol" do
      expect do
        state.ignore!("%s",
                      "a value")
      end.to throw_symbol(:ignore, be_kind_of(Remap::Notice))
    end
  end

  describe "#only" do
    subject(:result) { target.only(*keys) }

    context "when keys are empty" do
      let(:target) { hash! }
      let(:keys) { [] }

      it { is_expected.to be_empty }
    end

    context "when keys are not empty" do
      let(:keys) { [:a, :b] }

      context "when all keys exists" do
        let(:target) { { a: 1, b: 2 } }

        it { is_expected.to eq(target) }
      end

      context "when some keys exists" do
        let(:target) { { a: 1, c: 2 } }

        it { is_expected.to eq(target.except(:c)) }
      end

      context "when no keys exists" do
        let(:target) { { d: 1, e: 2 } }

        it { is_expected.to be_empty }
      end
    end
  end

  describe "#combine" do
    subject { left.combine(right) }

    context "when left has failures" do
      let(:left) { defined!({}, :with_failures) }

      context "when right has no failures" do
        let(:right) { defined!({}) }

        it { is_expected.not_to have_key(:value) }
      end
    end

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
      let(:left)  { defined!(10)     }
      let(:right) { defined!(:hello) }

      its(:itself) { will throw_symbol(:fatal, be_kind_of(Remap::Notice)) }
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

  describe "#failure" do
    subject(:state) { state!(value, path: path).failure(reason) }

    let(:value) { "value" }

    context "when state is without path" do
      let(:path) { [] }

      context "when reason is a string" do
        let(:reason) { "reason" }

        it {
          expect(state).to include(failures: [
            have_attributes(reason: "reason", value: value)
          ])
        }

        it { is_expected.not_to have_key(:value) }
      end

      context "when reason is an array" do
        let(:reason) { ["reason"] }

        it {
          expect(state).to include(failures: [
            have_attributes(reason: "reason", value: value)
          ])
        }

        it { is_expected.not_to have_key(:value) }
      end

      context "when reason is a hash" do
        let(:reason) { { key: ["error"] } }

        it {
          expect(state).to include(failures: [
            have_attributes(reason: "error", path: [:key], value: value)
          ])
        }
      end
    end

    context "when state has path" do
      let(:path) { [:a, :b] }

      context "when reason is a string" do
        let(:reason) { "reason" }

        it {
          expect(state).to include(failures: [
            have_attributes(reason: reason, value: value, path: [:a, :b])
          ])
        }

        it { is_expected.not_to have_key(:value) }
      end

      context "when reason is an array" do
        let(:reason) { ["reason"] }

        it {
          expect(state).to include(failures: [
            have_attributes(reason: "reason", value: value, path: [:a, :b])
          ])
        }

        it { is_expected.not_to have_key(:value) }
      end

      context "when reason is a hash" do
        let(:reason) { { c: ["reason"] } }

        it {
          expect(state).to include(failures: [
            have_attributes(reason: "reason", path: [:a, :b, :c], value: value)
          ])
        }

        it { is_expected.not_to have_key(:value) }
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
        expect(state.tap { :a_value }).to eq(state)
      end
    end
  end

  describe "#set" do
    let(:state) { defined! }
    let(:index) { 1       }
    let(:value) { "value" }

    context "when given an index" do
      subject(:result) { state.set(value, index: index) }

      it { is_expected.to include(index: index) }
      it { is_expected.to include(element: value) }
      it { is_expected.to contain(value) }
      it { is_expected.to include(path: state.path + [index]) }
    end

    context "when given a notice" do
      subject(:result) { state.set(notice: notice) }

      let(:notice) { notice! }

      it { is_expected.to include(notices: [notice]) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when given a failure" do
      subject(:result) { state.set(failure: notice) }

      let(:notice) { notice! }

      it { is_expected.to include(failures: [notice]) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when given failure" do
      subject(:result) { state.set(failures: [notice]) }

      let(:notice) { notice! }

      it { is_expected.to include(failures: [notice]) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when given a notice twice" do
      subject(:result) { state.set(notice: notice1).set(notice: notice2) }

      let(:notice1) { notice! }
      let(:notice2) { notice! }

      it { is_expected.to include(notices: [notice1, notice2]) }
      it { is_expected.not_to have_key(:value) }
    end

    context "when given just an index" do
      subject(:result) { state.set(index: index) }

      it { is_expected.to include(index: index) }
      it { is_expected.to include(path: state.path + [index]) }
    end

    context "when given a key" do
      subject(:result) { state.set(value, key: key) }

      let(:key) { :key }

      describe "#key" do
        subject { result.execute { key } }

        it { is_expected.to contain(key) }
        it { is_expected.to include(path: state.path + [key]) }
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

      let(:state)  { defined! }
      let(:mapper) { mapper!  }

      context "when given a mapper" do
        let(:options) { { mapper: mapper } }

        it "copies #value to #scope" do
          expect(result).to include(scope: state.value)
        end
      end
    end

    context "when state is undefined!" do
      subject(:result) { state.set(**options) }

      let(:state)  { undefined! }
      let(:mapper) { mapper!    }

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

      its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
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
      subject(:result) do
        state.execute { skip!("This is skipped!") }
      end

      let(:value) { "value" }
      let(:state) { defined!(value, path: [:key1]) }
      let(:notice) do
        { path: [:key1], reason: "This is skipped!", value: value }
      end

      it "throws symbol notice" do
        expect { result }.to throw_symbol(:ignore, be_a(Remap::Notice))
      end
    end

    context "when undefined! is returned" do
      subject(:result) do
        state.execute { undefined! }
      end

      let(:state) { defined! }

      it "throws symbol notice" do
        expect { result }.to throw_symbol(:notice, be_a(Remap::Notice))
      end
    end

    context "when #get is used" do
      context "when value exists" do
        subject do
          state.execute do
            value.get(:a, :b)
          end
        end

        let(:value) { { a: { b: "value" } } }
        let(:state) { defined!(value)       }

        it { is_expected.to contain("value") }
      end

      context "when value does not exists" do
        subject do
          state.execute do
            value.get(:a, :x)
          end
        end

        let(:state) { defined! }

        its(:itself) { will throw_symbol(:ignore, be_a(Remap::Notice)) }
      end
    end

    context "when KeyError is raised" do
      subject do
        state.execute do
          input.fetch(:does_not_exist)
        end
      end

      let(:value) { { key: "value" } }
      let(:state) { defined!(value)  }

      its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
    end

    context "when IndexError is raised" do
      subject do
        state.execute do
          value.fetch(10)
        end
      end

      let(:value) { [1, 2, 3] }
      let(:state) { defined!(value) }

      its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
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

      let(:key)   { :key                       }
      let(:state) { defined!(value!, path: []) }

      its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
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

        let(:state)  { defined! }
        let(:reason) { "reason" }

        its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
      end

      context "with pre-existing path" do
        context "without key argument" do
          subject do
            state.fmap do
              state.notice!(reason)
            end
          end

          let(:state) { defined!(1, path: [:key]) }
          let(:reason) { "reason" }

          its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
        end

        context "with key argument" do
          subject do
            state.fmap(key: :key2) do |_value, &error|
              error[reason]
            end
          end

          let(:state) { defined!(1, path: [:key1]) }
          let(:reason) { "reason" }

          its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
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
      let(:value) { "value"         }
      let(:state) { defined!(value) }

      its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
    end

    context "when error block is invoked" do
      subject do
        state.bind do |&error|
          error[reason]
        end
      end

      let(:state) { defined! }
      let(:reason) { "reason" }

      its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
    end
  end

  describe "#inspect" do
    subject { defined!.inspect }

    it { is_expected.to be_a(String) }
    it { is_expected.to include("#<State") }
  end

  describe "#paths" do
    context "when empty" do
      it "has no paths" do
        expect({}.paths).to eq([])
      end
    end

    context "when shallow" do
      it "has paths" do
        expect({ key: "value" }.paths).to eq([[:key]])
      end
    end

    context "when deep" do
      let(:input) do
        {
          shallow: "value",
          deep1: {
            deep2: "value"
          },
          deeper1: {
            deeper2: {
              deeper3: "value",
              deeper4: "value"
            },
            deeper5: {
              deeper6: "value"
            }
          }
        }.paths
      end

      it "has paths" do
        expect(input).to match_array([
          [:shallow],
          [:deep1, :deep2],
          [:deeper1, :deeper2, :deeper3],
          [:deeper1, :deeper2, :deeper4],
          [:deeper1, :deeper5, :deeper6]
        ])
      end
    end
  end
end
