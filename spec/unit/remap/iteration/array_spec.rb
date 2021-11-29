# frozen_string_literal: true

describe Remap::Iteration::Array do
  using Remap::State::Extension
  subject(:iterator) { described_class.call(state: state, value: value) }

  let(:state) { state!(value) }

  context "given an empty array" do
    let(:value) { [] }

    context "when called with a block" do
      it "does not yield block" do
        expect { |block| iterator.map(&block) }.not_to yield_control
      end

      it "contains the input value" do
        expect(iterator.map(&:itself)).to contain(value)
      end
    end
  end

  context "given a non-empty array" do
    let(:value) { [:one, :two, :tree].map(&:to_s) }

    context "when no values are rejected" do
      subject(:result) do
        iterator.map do |value|
          state.set(value.upcase)
        end
      end

      let(:output) { value.map(&:upcase) }

      it "contains the input value" do
        expect(result).to contain(output)
      end
    end

    context "when all values are rejected" do
      subject(:result) do
        iterator.map do |_value, index:|
          state.problem("P:#{index}")
        end
      end

      it "contains the correct problems" do
        expect(result).to have(3).problems
      end

      it "has an empty array as output" do
        expect(result).to contain([])
      end
    end
  end
end
