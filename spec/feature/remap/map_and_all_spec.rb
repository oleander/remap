# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map :people, all, :name, to: :names
        end
      end
    end

    let(:input) do
      { people: [{ name: "Skip" }, { name: "John" }] }
    end

    let(:output) do
      { names: %w[Skip John] }
    end
  end
end
