# frozen_string_literal: true

describe Remap::Rule::Embed do
  subject(:rule) { embed.call(state) }

  let(:mapper) do
    Class.new(Remap::Base) do
      define { map :a, to: :b }
    end
  end

  let(:value) { value!                       }
  let(:embed) { described_class.call(mapper) }

  context "when embeded mapper fails" do
    subject { mapper.call(state) }

    let(:input) { {} }
    let(:embeded) do
      mapper! do
        contract { required(:a).filled }
        define { map }
      end
    end
    let(:mapper) do |context: self|
      mapper! do
        define do
          embed context.embeded
        end
      end
    end
    let(:state) { state!(input) }

    it { is_expected.to have_problem }
  end

  context "when embeded mapper does not requires option" do
    context "when state is defined" do
      context "when embeded mapper passes" do
        let(:state) { state!({ a: value }) }

        it { is_expected.to contain(b: value) }
      end
    end
  end

  context "when embeded mapper requires option" do
    let(:name) { "Linus" }

    context "when state has option" do
      let(:mapper) do
        Class.new(Remap::Base) do
          option :name
          define { set :name, to: option(:name) }
        end
      end

      let(:state) { build(:element, options: { name: name }) }

      it { is_expected.to contain(name: name) }
    end

    context "when state does not have option" do
      let(:mapper) do
        Class.new(Remap::Base) do
          option :name
          define { set :name, to: option(:name) }
        end
      end

      let(:state) { state! }

      it "raises an argument error" do
        expect { rule }.to raise_error(Dry::Struct::Error)
      end
    end

    context "when mapper doesnt have the option" do
      let(:mapper) do
        Class.new(Remap::Base) do
          define { set :name, to: option(:name) }
        end
      end

      let(:state) { state! }

      it "raises an argument error" do
        expect { rule.call(state) }.to raise_error(ArgumentError)
      end
    end
  end
end
