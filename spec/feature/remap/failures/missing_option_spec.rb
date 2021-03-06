# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      option :key

      define do
        set :value, to: option(:does_not_exist)
      end
    end
  end

  it "raises an argument error" do
    expect { mapper.call(hash!, key: "KEY", &error) }.to raise_error(ArgumentError)
  end
end
