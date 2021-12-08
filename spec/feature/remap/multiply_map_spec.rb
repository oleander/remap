# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map :fish
          map :dog
          map :cat
        end
      end
    end

    let(:input) do
      { fish: { water: "fresh" }, dog: { food: "meat" }, cat: { purr: true } }
    end

    let(:output) do
      {
        water: "fresh",
        food: "meat",
        purr: true
      }
    end
  end
end
