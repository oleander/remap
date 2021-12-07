# frozen_string_literal: true

describe Remap::Extensions::Object do
  using described_class

  let(:target) { string! }

  describe "#get" do
    it "raises a path error" do
      expect { target.get(:a) }.to raise_error(Remap::PathError)
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
