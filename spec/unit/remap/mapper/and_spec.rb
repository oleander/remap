# frozen_string_literal: true

describe Remap::Mapper::And do
  using Remap::State::Extension

  let(:mapper) { described_class.new(left: left, right: right) }

  let(:left) do
    mapper! do
      contract { required(:a).filled }
      define { map :a }
    end
  end

  let(:right) do
    mapper! do
      contract { required(:b).filled }
      define { map :b }
    end
  end

  describe "::is_a?" do
    subject { mapper }

    it { is_expected.to be_a(Remap::Mapper) }
  end

  describe "#call" do
    subject(:result) { mapper.call(input) }

    let(:input) { hash! }

    context "when given input for both A and B" do
      subject(:result) { mapper.call(input) }

      let(:input) { { a: [:A], b: [:B] } }

      it "returns the result of A" do
        expect(result).to be_a_success([:A, :B])
      end
    end

    context "when A fails but not B" do
      let(:input) { { b: 1 } }

      it { is_expected.to be_a_failure }
    end

    context "when B fails but not A" do
      let(:input) { { a: 1 } }

      it { is_expected.to be_a_failure }
    end

    context "when A and B fails" do
      let(:input) { { x: 1 } }

      it { is_expected.to be_a_failure }
    end
  end
end
