# frozen_string_literal: true

describe Remap::Rule::Enum do
  shared_examples described_class do
    subject { enum[lookup] }

    it { is_expected.to match(output) }
  end

  let(:state) { build(:null) }

  describe "::call" do
    context "without block" do
      it "raises an ArgumentError" do
        expect { described_class.call }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#get" do
    subject(:enum) do
      described_class.call do
        value "ID"
      end
    end

    let(:context) { context! }

    context "when input is missing" do
      it "raises an error" do
        expect { enum.get("NOPE") }.to raise_error(Remap::Error)
      end
    end

    context "when input is not missing" do
      it "returns value" do
        expect(enum.get("ID")).to eq("ID")
      end
    end
  end

  describe "#[]" do
    context "without mappings" do
      it_behaves_like described_class do
        let(:lookup) { :does_not_exist }
        let(:output) { None()          }
        let(:enum) do
          described_class.call do
            # NOP
          end
        end
      end
    end

    context "with default value" do
      context "when key exist" do
        context "when not mapped to another value" do
          it_behaves_like described_class do
            let(:output) { Some(lookup) }
            let(:fallback) { :fallback }
            let(:lookup)   { :ID       }
            let(:enum) do |context: self|
              described_class.call do
                otherwise context.fallback
                value context.lookup
              end
            end
          end
        end

        context "when mapped from multiply values" do
          it_behaves_like described_class do
            let(:output) { Some(value) }
            let(:fallback) { :fallback        }
            let(:lookup)   { :ID              }
            let(:lookups)  { [lookup, :OTHER] }
            let(:value)    { :value           }
            let(:enum) do |context: self|
              described_class.call do
                otherwise context.fallback
                from(*context.lookups, to: context.value)
              end
            end
          end
        end

        context "when mapped to another value" do
          it_behaves_like described_class do
            let(:output) { Some(value) }
            let(:fallback) { :fallback }
            let(:lookup)   { :ID       }
            let(:value)    { :value    }
            let(:enum) do |context: self|
              described_class.call do
                otherwise context.fallback
                from context.lookup, to: context.value
              end
            end
          end
        end
      end

      context "when key does not exist" do
        it_behaves_like described_class do
          let(:output) { Some(fallback) }
          let(:fallback) { :fallback       }
          let(:lookup)   { :does_not_exist }
          let(:enum) do |context: self|
            described_class.call do
              otherwise context.fallback
            end
          end
        end
      end
    end

    context "without default value" do
      context "when key is not found" do
        it_behaves_like described_class do
          let(:output) { None() }
          let(:lookup) { :ID }
          let(:enum) do
            described_class.call do
              value :does_not_exist
            end
          end
        end
      end
    end

    context "with mappings" do
      context "when not found" do
        it_behaves_like described_class do
          let(:output) { None() }
          let(:lookup) { :does_not_exist }
          let(:enum) do
            described_class.call do
              value :ID
            end
          end
        end
      end

      context "when found" do
        it_behaves_like described_class do
          let(:output) { Some(lookup) }
          let(:lookup) { :ID }
          let(:enum) do
            described_class.call do
              value :ID
            end
          end
        end
      end

      context "when to: is found, but not from:" do
        it_behaves_like described_class do
          let(:output) { Some(lookup) }
          let(:lookup) { :ID }
          let(:enum) do
            described_class.call do
              from :MISSING, to: :ID
            end
          end
        end
      end
    end
  end
end
