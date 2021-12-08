# frozen_string_literal: true

describe Remap::Base do
  using Remap::Extensions::Enumerable
  using Remap::State::Extension

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

  it "invokes block with failure" do
    expect { |error| mapper.call(input, &error) }.to yield_with_args(Remap::Failure)
  end
end
