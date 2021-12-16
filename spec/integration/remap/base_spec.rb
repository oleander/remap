# frozen_string_literal: true

describe Remap::Base do
  context "when using #embed" do
    subject(:result) { mapper.call(value) }

    let(:output) { ["<RESULT>"] }

    let(:pass) do |context: self|
      mapper! do
        define do
          map.adjust do
            context.output
          end
        end
      end
    end

    let(:value) { value! }

    let(:fail) do
      mapper! do
        contract { required(:something).filled }
      end
    end

    describe "or" do
      let(:mapper) do |context: self|
        mapper! do
          define do
            embed context.left | context.middle | context.right
          end
        end
      end

      context "when left passes" do
        let(:left)   { pass }
        let(:middle) { fail }
        let(:right)  { fail }

        it { is_expected.to eq(output) }
      end

      context "when middle passes" do
        let(:left) { fail }
        let(:middle) { pass }
        let(:right)  { fail }

        it { is_expected.to eq(output) }
      end

      context "when right passes" do
        let(:left) { fail }
        let(:middle) { fail }
        let(:right)  { pass }

        it { is_expected.to eq(output) }
      end

      context "when all passes" do
        let(:left) { pass }
        let(:middle) { pass }
        let(:right)  { pass }

        it { is_expected.to eq(output) }
      end
    end

    describe "one" do
      let(:mapper) do |context: self|
        mapper! do
          define do
            embed context.that
          end
        end
      end

      context "when it fails" do
        let(:that) { fail }

        it "yields failure" do
          expect { |error| mapper.call(value, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
        end
      end

      context "when it passes" do
        let(:that) { pass }

        it { is_expected.to eq(output) }
      end
    end

    describe "and" do
      let(:mapper) do |context: self|
        mapper! do
          define do
            embed context.left & context.middle & context.right
          end
        end
      end

      context "when left passes" do
        let(:left) { pass }
        let(:middle) { fail }
        let(:right)  { fail }

        it "yields failure" do
          expect { |error| mapper.call(value, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
        end
      end

      context "when middle passes" do
        let(:left) { fail }
        let(:middle) { pass }
        let(:right)  { fail }

        it "yields failure" do
          expect { |error| mapper.call(value, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
        end
      end

      context "when right passes" do
        let(:left) { fail }
        let(:middle) { fail }
        let(:right)  { pass }

        it "yields failure" do
          expect { |error| mapper.call(value, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
        end
      end

      context "when all passes" do
        let(:left) { pass }
        let(:middle) { pass }
        let(:right)  { pass }

        it { is_expected.to eq(["<RESULT>"] * 3) }
      end
    end

    describe "xor" do
      let(:mapper) do |context: self|
        mapper! do
          define do
            embed context.left ^ context.middle ^ context.right
          end
        end
      end

      context "when left passes" do
        let(:left) { pass }
        let(:middle) { fail }
        let(:right)  { fail }

        it { is_expected.to eq(output) }
      end

      context "when middle passes" do
        let(:left) { fail }
        let(:middle) { pass }
        let(:right)  { fail }

        it { is_expected.to eq(output) }
      end

      context "when right passes" do
        let(:left) { fail }
        let(:middle) { fail }
        let(:right)  { pass }

        it { is_expected.to eq(output) }
      end
    end
  end

  describe "::rule" do
    subject { mapper.call(input) }

    let(:input) { { key: "value" } }

    context "when failing" do
      let(:mapper) do
        Class.new(described_class) do
          rule(:key) do
            key.failure("key is missing")
          end
        end
      end

      it "invokes block with failure" do
        expect { |error| mapper.call(input, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
      end
    end

    context "when passing" do
      let(:mapper) do
        Class.new(described_class) do
          rule(:key) do
            # NOP
          end
        end
      end

      it { is_expected.to eq(input) }
    end
  end

  describe "::define" do
    subject { mapper.new(**options) }

    let(:id) { value! }

    context "when accessed from #adjust" do
      let(:mapper) do
        Class.new(described_class) do
          option :id

          define do
            map.adjust { |id:| id }
          end
        end
      end

      let(:state) { state!(10) }

      context "when state contains options" do
        context "when rule accesses option" do
          subject { mapper.call(value!, id: id) }

          it { is_expected.to eq(id) }
        end
      end
    end

    context "when accessed from #set" do
      let(:mapper) do
        Class.new(described_class) do
          option :id

          define do
            set :id, to: option(:id)
          end
        end
      end

      context "when state contains options" do
        context "when rule accesses option" do
          subject(:result) { mapper.call(value!, id: id) }

          it { is_expected.to eq(id: id) }
        end
      end

      context "when mapper contains options" do
        context "when rule accesses option" do
          subject(:context) { mapper.call(value!) }

          it "raises an argument error" do
            expect { context }.to raise_error(Dry::Struct::Error)
          end
        end
      end
    end
  end
end
