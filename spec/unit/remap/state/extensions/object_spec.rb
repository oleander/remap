# frozen_string_literal: true

describe Remap::State::Extensions::Object do
  using described_class

  let(:target) { string! }

  describe "#get" do
    it "throws a symbol containing the path" do
      expect { target.get(:a) }.to throw_symbol(:missing, [:a])
    end
  end

  describe "#_" do
    context "given a block" do
      it "invokes block" do
        expect { |b| target._(&b) }.to yield_control
      end
    end

    context "given no block" do
      it "raises a runtime error" do
        expect { target._ }.to raise_error(RuntimeError)
      end
    end
  end
end
