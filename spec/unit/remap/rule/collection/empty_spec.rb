# frozen_string_literal: true

# custom rspec matcher with chain

describe Remap::Rule::Collection::Empty do
  describe "#call" do
    let(:rule) { described_class.new({}) }

    it "throws a symbol" do
      expect do
        rule.call(state!)
      end.to throw_symbol(:notice, be_a(Remap::Notice))
    end
  end
end
