# frozen_string_literal: true

describe Remap::Iteration::Array do
  using Remap::State::Extension
  subject(:iterator) { described_class.call(state: state, value: value) }

  let(:state) { state!(value, :with_fatal_id, id: :ignore) }

  context "given an empty array" do
    let(:value) { [] }

    context "when called with a block" do
      it "does not yield block" do
        expect { |block| iterator.call(&block) }.not_to yield_control
      end

      it "contains the input value" do
        expect(iterator.call(&:itself)).to contain(value)
      end
    end
  end

  context "given a non-empty array" do
    let(:value) { [:one, :two, :tree].map(&:to_s) }

    context "when no values are rejected" do
      subject(:result) do
        iterator.call do |value|
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
        iterator.call do
          state.ignore!("Ignore!")
        end
      end

      it "raises a fatal exception" do
        expect { result }.to throw_symbol(
          :ignore, include(
            notices: contain_exactly(
              an_instance_of(Remap::Notice).and(
                having_attributes(
                  reason: "Ignore!"
                )
              )
            )
          )
        )
      end
    end
  end
end
