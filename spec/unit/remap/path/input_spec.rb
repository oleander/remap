# frozen_string_literal: true

describe Remap::Path::Input do
  using Remap::State::Extension

  describe "#call" do
    subject(:path) { described_class.call(selectors) }

    let(:fatal_id) { :fatal_id }
    let(:state) { state!(input, fatal_id: fatal_id) }

    context "without selectors" do
      let(:input) { "value" }
      let(:selectors) { [] }

      it "does not yield" do
        expect { |iterator| path.call(state, &iterator) }.to yield_with_args(contain(input))
      end
    end

    context "with key" do
      let(:selectors) { [:key] }

      context "when the key is present" do
        let(:value) { "value" }
        let(:input) { { key: value } }

        it "yields the value" do
          expect { |iterator| path.call(state, &iterator) }.to yield_successive_args(contain(value))
        end
      end

      xcontext "when the key is not present" do
        let(:value) { "value" }
        let(:input) { { not: value } }

        it "raises a fatal exception" do
          expect { path.call(state, &error) }.to raise_error(
            an_instance_of(Remap::Notice::Ignore).and(
              having_attributes(
                path: selectors,
                value: input
              )
            )
          )
        end
      end
    end

    context "with a single 'all' selector" do
      let(:selectors) { [all!] }

      context "when input is an array" do
        subject(:result) do
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
        subject(:result) do
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
        subject(:result) do
          path.call(state) do |_element|
            fail "This should not be called"
          end
        end

        let(:input) { 100_000 }

        it "raises a fatal exception" do
          expect { result }.to throw_symbol(
            fatal_id, an_instance_of(Remap::Failure).and(
              having_attributes(
                failures: contain_exactly(
                  an_instance_of(Remap::Notice).and(
                    having_attributes(
                      value: input
                    )
                  )
                )
              )
            )
          )
        end
      end
    end

    context "with 'all' selector and a key" do
      let(:selectors) { [all!, :key] }

      context "when input is an array" do
        subject(:result) do
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
        subject(:result) do
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
        subject(:result) { path.call(state, &error) }

        let(:input) { 100_000 }

        it "raises a fatal exception" do
          expect { result }.to throw_symbol(
            fatal_id, an_instance_of(Remap::Failure).and(
              having_attributes(
                failures: contain_exactly(
                  an_instance_of(Remap::Notice).and(
                    having_attributes(
                      value: input
                    )
                  )
                )
              )
            )
          )
        end
      end
    end

    context "with index" do
      let(:selectors) { [index!(1)] }

      context "when the index is present" do
        subject(:result) do
          path.call(state) do |element|
            element.fmap do |value|
              value.upcase
            end
          end
        end

        let(:input) { [:one, :two] }

        it { is_expected.to contain(:TWO) }
      end

      xcontext "when the key is not present" do
        let(:input) { [:one] }

        it "raises an ignore exception" do
          expect { path.call(state, &error) }.to raise_error(
            an_instance_of(Remap::Notice::Ignore).and(
              having_attributes(
                path: [1],
                value: input
              )
            )
          )
        end
      end
    end
  end
end
