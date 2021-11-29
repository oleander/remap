# frozen_string_literal: true

describe Remap::Base do
  context "when using #embed" do
    subject { mapper.call(value) }

    let(:pass) do
      mapper! do
        define do
          map.adjust do
            "<RESULT>"
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
        let(:left) { pass }
        let(:middle) { fail }
        let(:right) { fail }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
      end

      context "when middle passes" do
        let(:left) { fail }
        let(:middle) { pass }
        let(:right) { fail }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
      end

      context "when right passes" do
        let(:left) { fail }
        let(:middle) { fail }
        let(:right) { pass }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
      end

      context "when all passes" do
        let(:left) { pass }
        let(:middle) { pass }
        let(:right) { pass }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
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

        it { is_expected.to have_problem }
      end

      context "when it passes" do
        let(:that) { pass }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
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
        let(:right) { fail }

        it { is_expected.to have_problem }
      end

      context "when middle passes" do
        let(:left) { fail }
        let(:middle) { pass }
        let(:right) { fail }

        it { is_expected.to have_problem }
      end

      context "when right passes" do
        let(:left) { fail }
        let(:middle) { fail }
        let(:right) { pass }

        it { is_expected.to have_problem }
      end

      context "when all passes" do
        let(:left) { pass }
        let(:middle) { pass }
        let(:right) { pass }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
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
        let(:right) { fail }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
      end

      context "when middle passes" do
        let(:left) { fail }
        let(:middle) { pass }
        let(:right) { fail }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
      end

      context "when right passes" do
        let(:left) { fail }
        let(:middle) { fail }
        let(:right) { pass }

        it { is_expected.to be_a_success.and(have_attributes(result: "<RESULT>")) }
      end

      xcontext "when all passes" do
        let(:left) { pass }
        let(:middle) { pass }
        let(:right) { pass }

        it { is_expected.to have_problem }
      end
    end
  end

  describe "::rule" do
    subject { mapper.call(state) }

    let(:state) { state!({ key: "okay" }) }

    context "when failing" do
      let(:mapper) do
        Class.new(described_class) do
          rule(:key) do
            key.failure("key is missing")
          end
        end
      end

      it { is_expected.to be_a_failure }
    end

    context "when passing" do
      let(:mapper) do
        Class.new(described_class) do
          rule(:key) do
            # NOP
          end
        end
      end

      it { is_expected.to be_a_success }
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
            map.adjust { id }
          end
        end
      end

      let(:state) { state!(10) }

      context "when state contains options" do
        context "when rule accesses option" do
          subject { mapper.call(value!, id: id) }

          it { is_expected.to be_a_success.and(have_attributes(result: id)) }
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
          subject { mapper.call(value!, id: id) }

          it { is_expected.to be_a_success.and(have_attributes(result: { id: id })) }
        end
      end

      context "when mapper contains options" do
        context "when rule accesses option" do
          subject(:context) { mapper.call(value!) }

          it "raises an argument error" do
            expect { context }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
