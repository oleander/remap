# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class, key: "KEY" do
    let(:mapper) do
      mapper! do
        option :key

        define do
          set :value, to: option(:does_not_exist)
        end
      end
    end

    let(:input) { hash! }

    let(:output) do
      { failure: { base: be_a(Array) } }
    end
  end
end
