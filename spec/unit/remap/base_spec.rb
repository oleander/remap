# frozen_string_literal: true

describe Remap::Base do
  let(:left) do
    Class.new(described_class) do
      define { map :a }
    end
  end

  let(:right) do
    Class.new(described_class) do
      define { map :b }
    end
  end

  describe "::is_a?" do
    subject { described_class.new }

    it { is_expected.to be_a(Remap::Mapper) }
  end

  describe "::|" do
    subject { left | right }

    it { is_expected.to be_a(Remap::Mapper) }
  end

  describe "::inspect" do
    subject(:mapper) do
      mapper! do
        contract { required(:a) }
      end
    end

    it { is_expected.to have_attributes(inspect: be_a(String)) }
  end

  describe "::call" do
    context "when contract fails" do
      let(:input) { { b: 1 } }

      let(:mapper) do
        mapper! do
          contract { required(:a) }
        end
      end

      it "yields failure" do
        expect { |error| mapper.call(input, &error) }
      end
    end

    context "when mapper returns nothing" do
      let(:input) { { a: 1 } }

      let(:mapper) do
        mapper! do
          define do
            map.then do
              skip!
            end
          end
        end
      end

      it "yields failure" do
        expect { |error| mapper.call(input, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
      end
    end

    context "when mapper returns nothing with problems" do
      let(:input) { { a: "A" } }

      let(:mapper) do
        mapper! do
          define do
            map(:a).then { skip!("A problem") }
          end
        end
      end

      it "yields failure" do
        expect { |error| mapper.call(input, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
      end
    end

    context "when mapper succeedes" do
      subject(:result) { mapper.call(input) }

      let(:input) { { a: 1 } }
      let(:mapper) do
        mapper! do
          contract { required(:a) }
        end
      end

      it { is_expected.to eq(input) }
    end
  end
end
