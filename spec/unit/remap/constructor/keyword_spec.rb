# frozen_string_literal: true

RSpec.describe Remap::Constructor::Keyword do
  describe "#call" do
    subject(:result) { constructor.call(state) }

    let(:method) { :new       }
    let(:target) { OpenStruct }
    let(:constructor) do
      described_class.new(strategy: :keyword, method: method, target: target)
    end

    context "when state is not a hash" do
      let(:state) { state!(:foo) }

      it "raises an argument error" do
        expect { result }.to raise_error(ArgumentError)
      end
    end

    context "when state is a hash" do
      let(:value) { { input: "a value" } }
      let(:state) { state!(value)        }

      context "when target requires keyword arguments" do
        let(:target) { Struct.new(:input, keyword_init: true) }

        it "returns a struct with value set" do
          expect(result).to contain(target.new(**value))
        end
      end

      context "when target requires regular arguments" do
        let(:target) { -> a, b { a + b } }

        context "when method is defined on object" do
          let(:method) { :call }

          it "raises an argument error" do
            expect { result }.to raise_error(ArgumentError)
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
end
