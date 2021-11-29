# frozen_string_literal: true

describe Remap::Types do
  describe described_class::State do
    context "given valid input" do
      it "does not invoke block" do
        expect { |b| described_class.call(state!, &b) }.not_to yield_control
      end
    end

    context "given invalid input" do
      it "does invoke block" do
        expect { |b| described_class.call({}, &b) }.to yield_control
      end
    end

    it "does not raise an error" do
      expect { described_class.call(state!) }.not_to raise_error
    end
  end

  describe described_class::Problem do
    let(:valid) { { reason: "reason", value: "a value", path: [:a, :b] } }

    it "does not invoke block" do
      expect { |b| described_class.call(valid, &b) }.not_to yield_control
    end

    context "when path is empty" do
      let(:input) { valid.merge(path: []) }

      it "invokes block" do
        expect { |b| described_class.call(input, &b) }.to yield_control
      end
    end

    context "when path is missing" do
      let(:input) { valid.except(:path) }

      it "does not invokes block" do
        expect { |b| described_class.call(input, &b) }.not_to yield_control
      end
    end

    context "when reason is empty" do
      let(:input) { valid.merge(reason: "") }

      it "invokes block" do
        expect { |b| described_class.call(input, &b) }.to yield_control
      end
    end

    context "when value is missing" do
      let(:input) { valid.except(:value) }

      it "does not invokes block" do
        expect { |b| described_class.call(input, &b) }.not_to yield_control
      end
    end
  end

  describe "::not" do
    context "given a string type" do
      subject(:type) { described_class::String }

      context "when passing a string" do
        let(:string) { string! }

        it "does not invoke block" do
          expect { |b| type[string, &b] }.not_to yield_control
        end
      end

      context "when passing a symbol" do
        let(:symbol) { string!.to_sym }

        it "does not invoke block" do
          expect { |b| type[symbol, &b] }.to yield_control
        end
      end

      context "when a custom class can be passed without name" do
        subject { type.not }

        let(:type) { Remap::Types::String }

        context "when passing a string" do
          it "invokes block" do
            expect { |b| type[string!, &b] }.not_to yield_control
          end
        end

        context "when passing a symbol" do
          it "does not invoke block" do
            expect { |b| type[symbol!, &b] }.to yield_control
          end
        end
      end

      context "when a custom class can be passed" do
        subject { type.not(owner) }

        let(:type) { Remap::Types::String }
        let(:owner) { Hash }

        context "when passing a string" do
          it "invokes block" do
            expect { |b| type[string!, &b] }.not_to yield_control
          end
        end

        context "when passing a symbol" do
          it "does not invoke block" do
            expect { |b| type[symbol!, &b] }.to yield_control
          end
        end
      end

      context "when reversed" do
        subject(:reversed) { type.not(Symbol) }

        context "when passing a string" do
          it "invokes block" do
            expect { |b| reversed[string!, &b] }.to yield_control
          end
        end

        context "when passing a symbol" do
          it "does not invoke block" do
            expect { |b| reversed[symbol!, &b] }.not_to yield_control
          end
        end
      end

      context "when reversed again" do
        subject(:reversed_again) { type.not(Hash) }

        context "when passing a string" do
          it "invokes block" do
            expect { |b| reversed_again[hash!, &b] }.not_to yield_control
          end
        end

        context "when passing a symbol" do
          it "does not invoke block" do
            expect { |b| reversed_again[symbol!, &b] }.to yield_control
          end
        end
      end
    end
  end

  describe "::call" do
    describe described_class::Nothing do
      context "when undefined" do
        subject { described_class.call(input) }

        let(:input) { Remap::Nothing }
        let(:output) { input }

        it { is_expected.to eq(output) }
      end
    end
  end
end
