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
            state.problem("an error")
          end
        end

        let(:value) { [1, 2, 3] }
        let(:output) { value.size }

        its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
      end

      context "when error block is not invoked" do
        subject(:result) do
          other.call do |value|
            state.set(value.size)
          end
        end

        let(:value) { [1, 2, 3] }
        let(:output) { value.size }

        it { is_expected.to contain(output) }
      end
    end
  end
end
