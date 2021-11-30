# frozen_string_literal: true

describe Remap::Notice::Untraced do
  subject(:notice) { described_class.call(input) }

  let(:input) { { path: [:a, :b, :c], value: value!, reason: string! } }

  describe "#inspect" do
    it { is_expected.to have_attributes(inspect: start_with("#<Untraced")) }
  end

  describe "#exception" do
    it { is_expected.to have_attributes(exception: be_a(Remap::Error)) }
  end

  describe "#traced" do
    subject { notice.traced(["backtrace"]) }

    it { is_expected.to be_a(Remap::Notice::Traced) }
  end
end
