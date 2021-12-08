# frozen_string_literal: true

describe Remap::Rule::Wrap do
  describe "#call" do
    subject { wrap.call(state, &error) }

    let(:wrap) { described_class.new(type: type, rule: rule) }
    let(:type) { :array                                      }
    let(:rule) { void!                                       }

    let(:state) { state!([1, 2, 3]) }

    it { is_expected.to contain([1, 2, 3]) }
  end

  describe "::new" do
    context "when type is not :array" do
      it "raises an error" do
        expect do
          described_class.new(type: :foo,
                              rule: void!)
        end.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
