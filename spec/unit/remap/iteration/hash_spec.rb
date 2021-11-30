# frozen_string_literal: true

# custom rspec match with custom error message
describe Remap::Iteration::Hash do
  using Remap::State::Extension

  subject(:iterator) { described_class.call(state: state, value: value) }

  let(:state) { state!(value) }

  context "given an empty hash" do
    let(:value) { {} }

    context "when called with a block" do
      subject do
        iterator.call do |value, key:|
          state.set(value, key: key)
        end
      end

      it { is_expected.to include(value: value) }
    end
  end

  context "given a non-empty hash" do
    let(:value) { { a: 1, b: 2, c: 3 } }

    context "when no values are rejected" do
      subject(:result) do
        iterator.call do |value|
          state.set(value.next)
        end
      end

      let(:output) { value.transform_values(&:next) }

      it "includes the input value" do
        expect(result).to contain(output)
      end
    end

    context "when all values are rejected" do
      subject(:result) do
        iterator.call do |_value, key:|
          state.notice!("P:#{key}")
        end
      end

      its(:itself) { will throw_symbol(:notice, be_a(Remap::Notice)) }
    end
  end
end
