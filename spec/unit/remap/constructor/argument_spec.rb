# frozen_string_literal: true

RSpec.describe Remap::Constructor::Argument do
  describe "#call" do
    subject(:result) { constructor.call(state) }

    let(:constructor) { described_class.new(method: method, target: target) }
    let(:method) { :new }

    let(:value) { 100 }
    let(:state) { state!(value) }

    context "when target requires keyword arguments" do
      let(:target) { Struct.new(:value, keyword_init: true) }

      it "raises an argument error" do
        expect { result }.to raise_error(ArgumentError)
      end
    end

    context "when target requires regular arguments" do
      let(:target) { Struct.new(:value) }

      context "when method is defined on object" do
        let(:method) { :new }

        it "returns a struct with value set" do
          expect(result).to contain(target.new(value))
        end
      end

      context "when method is not defined on object" do
        let(:method) { :does_not_exist }

        it "raises an argument error" do
          expect { result }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
