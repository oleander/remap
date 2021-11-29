# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:car) do
      mapper! do
        define do
          map :model, to: :name
        end
      end
    end

    let(:mapper) do |context: self|
      mapper! do
        define do
          map :car do
            embed context.car
          end
        end
      end
    end

    let(:input) do
      { car: { model: "Ford" } }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { name: "Ford" }))
    end
  end
end
