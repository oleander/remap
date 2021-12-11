# frozen_string_literal: true

describe Remap::Iteration::Other do
  using Remap::State::Extension

  describe "#map" do
    let(:state) { state!(value)                                    }
    let(:other) { described_class.call(state: state, value: value) }

    context "when called with a defined value" do
      context "when error block is invoked" do
        subject(:result) do
          other.call do |_value|
            fail "this is not called"
          end
        end

        let(:value) { [1, 2, 3] }
        let(:output) { value.size }

        it "raises a fatal exception" do
          expect { result }.to raise_error(
            an_instance_of(Remap::Notice::Fatal).and(
              having_attributes(
                value: value
              )
            )
          )
        end
      end

      context "when error block is not invoked" do
        subject(:result) do
          other.call do |value|
            state.set(value.size)
          end
        end

        let(:value) { [1, 2, 3] }
        let(:output) { value.size }

        it "raises an fatal exception" do
          expect { result }.to raise_error(Remap::Notice::Fatal)
        end
      end
    end
  end
end
