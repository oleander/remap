# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
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

    let(:output) do
      be_a_failure.and(have_attributes(failures: be_present))
    end
  end
end
