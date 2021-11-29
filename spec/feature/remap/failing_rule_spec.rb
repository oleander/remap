# frozen_string_literal: true

describe Remap::Base do
  using Remap::State::Extensions::Enumerable
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
      { age: 10 }
    end

    let(:output) do
      be_a_failure.and(have_attributes(reasons: { age: ["too young"] } ))
    end
  end
end
