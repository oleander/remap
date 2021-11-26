# frozen_string_literal: true

# custom rspec matcher with chain

describe Remap::Rule::Collection::Empty do
  describe "#call" do
    subject { rule.call(state) }

    let(:rule) { described_class.new({}) }
    let(:state) { state! }

    it { is_expected.to have(1).problems }
  end
end
