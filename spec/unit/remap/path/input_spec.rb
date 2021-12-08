# frozen_string_literal: true

describe Remap::Path::Input do
  using Remap::State::Extension

  describe "#call" do
    let(:state) { state!(input) }
    let(:path)  { described_class.call(segments) }

    context "without segments" do
      let(:input) { "value" }
      let(:segments) { [] }

      it "does not yield" do
        expect { |iterator| path.call(state, &iterator) }.to yield_with_args(contain(input))
      end
    end

    context "with key" do
      let(:segments) { [:key] }

      context "when the key is present" do
        let(:value) { "value" }
        let(:input) { { key: value } }

        it "yields the value" do
          expect { |iterator| path.call(state, &iterator) }.to yield_successive_args(contain(value))
        end
      end

      context "when the key is not present" do
        let(:value) { "value" }
        let(:input) { { not: value } }

        it "throws an ignore symbol" do
          expect { path.call(state, &error) }.to throw_symbol(:ignore)
        end
      end
    end

    context "with a single 'all' selector" do
      let(:segments) { [all!] }

      context "when input is an array" do
        subject do
          path.call(state) do |element|
            element.fmap do |value|
              value.upcase
            end
          end
        end

        let(:input) { [:one, :two] }

        it { is_expected.to contain([:ONE, :TWO]) }
      end

      context "when input is a hash" do
        subject do
          path.call(state) do |element|
            element.fmap do |value|
              value.upcase
            end
          end
        end

        let(:input) { { key1: "value1", key2: "value2" } }

        it { is_expected.to contain({ key1: "VALUE1", key2: "VALUE2" }) }
      end

      context "when input is not an enumerable" do
        let(:input) { 100_000 }

        it "raises an error" do
          expect { path.call(state, &error) }.to throw_symbol(:fatal)
        end
      end
    end

    context "with 'all' selector and a key" do
      let(:segments) { [all!, :key] }

      context "when input is an array" do
        subject do
          path.call(state) do |element|
            element.fmap do |value|
              value.upcase
            end
          end
        end

        let(:input) { [{ key: "value1" }, { key: "value2" }] }

        it { is_expected.to contain(["VALUE1", "VALUE2"]) }
      end

      context "when input is a hash" do
        subject do
          path.call(state) do |element|
            element.fmap do |value|
              value.upcase
            end
          end
        end

        let(:item) { { key: "value1" } }
        let(:input) { { out1: item, out2: item } }

        it { is_expected.to contain({ out1: "VALUE1", out2: "VALUE1" }) }
      end

      context "when input is not an enumerable" do
        let(:input) { 100_000 }

        it "raises an error" do
          expect { path.call(state, &error) }.to throw_symbol(:fatal)
        end
      end
    end

    context "with index" do
      let(:segments) { [index!(1)] }

      context "when the index is present" do
        subject do
          path.call(state) do |element|
            element.fmap do |value|
              value.upcase
            end
          end
        end

        let(:input) { [:one, :two] }

        it { is_expected.to contain(:TWO) }
      end

      context "when the key is not present" do
        let(:input) { [:one] }

        it "yields failure" do
          expect { path.call(state, &error) }.to throw_symbol(:ignore)
        end
      end
    end
  end
end
