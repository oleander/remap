# frozen_string_literal: true

xdescribe Remap::Mapper::Xor do
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

    context "when given input for both A and B" do
      let(:input) { { a: [:A], b: [:B] } }

      it "invokes block with problem" do
        expect { |b| mapper.call!(state, &b) }.to yield_control
      end
    end

    context "when A fails but not B" do
      subject(:result) { mapper.call!(state) }

      let(:input) { { b: 1 } }

      it { is_expected.to contain(input) }
    end

    context "when B fails but not A" do
      subject(:result) { mapper.call!(state) }

      let(:input) { { a: 1 } }

      it { is_expected.to contain(input) }
    end

    context "when both A and B fails" do
      subject { mapper.call!(state, &:itself) }

      let(:input) { { c: 1 } }

      it "invokes block with problem" do
        expect { |b| mapper.call!(state, &b) }.to yield_with_args(be_a(Remap::Failure))
      end
    end
  end
end
