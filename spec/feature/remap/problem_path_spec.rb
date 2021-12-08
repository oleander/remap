# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      define do
        map?(:a, :b, :missing)
      end
    end
  end

  let(:input) do
    { a: { b: { c: 1 } } }
  end

  it "invokes block with failure" do
    expect { |error| mapper.call(input, &error) }.to yield_with_args(Remap::Failure)
  end
end
