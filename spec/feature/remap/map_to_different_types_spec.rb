# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      define do
        map :string
        map :array
        map :hash
      end
    end
  end

  let(:input) do
    { string: "string", array: [1, 2, 3], hash: { a: 1, b: 2 } }
  end

  it "invokes block with failure" do
    expect { |error| mapper.call(input, &error) }.to yield_with_args(Remap::Failure)
  end
end
