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

  it "raises error" do
    expect { mapper.call(input) }.to raise_error(Remap::Failure::Error)
  end
end
