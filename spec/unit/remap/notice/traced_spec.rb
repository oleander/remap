# frozen_string_literal: true

describe Remap::Notice::Traced do
  subject(:notice) { described_class.call(input) }

  let(:input) { { path: [:a, :b, :c], value: value!, reason: string! } }

  describe "#inspect" do
    it { is_expected.to have_attributes(inspect: start_with("#<Traced")) }
  end

  describe "#exception" do
    it { is_expected.to have_attributes(exception: be_a(Remap::Error)) }
  end

  describe "#traced" do
    xit "raises an argument error" do
      expect { notice.traced(["backtrace"]) }.to raise_error(ArgumentError)
    end
  end
end
