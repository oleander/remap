# frozen_string_literal: true

xdescribe Remap::Mapper::Or do
  using Remap::State::Extension

  let(:mapper) { described_class.new(left: left, right: right) }

  let(:left) do
    mapper! do
      contract { required(:a).filled }
    end
  end

  let(:right) do
    mapper! do
      contract { required(:b).filled }
    end
  end

  describe "::is_a?" do
    subject { mapper }

    it { is_expected.to be_a(Remap::Mapper) }
  end

  describe "#call" do
    let(:state) { state!(input) }

    context "given input for A" do
      subject(:result) { mapper.call!(state) }

      let(:input) { { a: 1 } }

      it "returns the result of A" do
        expect(result).to contain(input)
      end
    end

    context "given input for B" do
      subject(:result) { mapper.call!(state) }

      let(:input) { { b: 1 } }

      it "returns the result of B" do
        expect(result).to contain(input)
      end
    end

    context "when both fail" do
      let(:input) { { c: 1 } }

      it "invokes block with error" do
        expect { |b| mapper.call!(state, &b) }.to yield_control
      end
    end
  end
end
