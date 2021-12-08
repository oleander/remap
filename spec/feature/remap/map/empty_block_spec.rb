# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      define do
        map do
          # NOP
        end
      end
    end
  end

  let(:input) do
    { a: 1, b: 2 }
  end

  it "yields failure" do
    expect { |error| mapper.call(input, &error) }.to yield_control
  end
end
