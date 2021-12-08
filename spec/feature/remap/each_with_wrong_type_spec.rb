# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      define do
        set to: value([1, 2, 3])
        each do
          map? :names
        end
      end
    end
  end

  let(:input) do
    "not-an-array"
  end

  it "invokes block with failure" do
    expect { |error| mapper.call(input, &error) }.to yield_with_args(Remap::Failure)
  end
end
