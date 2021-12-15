# frozen_string_literal: true

describe Remap::Iteration::Other do
  using Remap::State::Extension

  describe "#map" do
    let(:state) { state!(value, fatal_id: :fatal) }
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

        it_behaves_like "a fatal exception" do
          let(:attributes) do
            { value: value }
          end
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

        it_behaves_like "a fatal exception" do
          let(:attributes) do
            { value: value }
          end
        end
      end
    end
  end
end
