# frozen_string_literal: true

describe Remap::Selector::All do
  using Remap::State::Extension

  describe "::call" do
    context "when called with a hash" do
      subject { described_class.call({}) }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#call" do
    subject(:selector) { described_class.call({}) }

    let(:fatal_id) { :fatal_id }
    let(:state) { state!(input, fatal_id: fatal_id) }

    context "with block" do
      context "when enumerable" do
        subject do
          selector.call(state) do |state|
            state.fmap do |value|
              value.next
            end
          end
        end

        let(:input) { [1, 2, 3] }

        it { is_expected.to contain([2, 3, 4]) }
      end

      context "when not enumerable" do
        subject(:result) { selector.call(state, &error) }

        let(:input) { 100 }

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
  end
end
