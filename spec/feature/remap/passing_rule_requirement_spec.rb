# frozen_string_literal: true

describe Remap::Base do
  using Remap::Extensions::Enumerable
  using Remap::State::Extension

  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        contract do
          required(:age).filled(:integer)
        end

        rule(:age) do
          unless value >= 18
            key.failure("too young")
          end
        end

        define do
          map :age, to: [:person, :age]
        end
      end
    end

    let(:input) do
      { age: 30 }
    end

    let(:output) do
      { person: { age: 30 } }
    end
  end
end
