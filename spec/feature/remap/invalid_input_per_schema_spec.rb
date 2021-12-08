# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      contract do
        required(:people).filled(:array)
      end
    end
  end

  let(:input) do
    { people: { name: "John" } }
  end

  it "invokes block with failure" do
    expect { |error| mapper.call(input, &error) }.to yield_with_args(Remap::Failure)
  end
end
