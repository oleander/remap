# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          set to: value([1, 2, 3])
          each do
            map :names
          end
        end
      end
    end

    let(:input) do
      "not-an-array"
    end

    let(:output) do
      [1, 2, 3]
    end
  end
end
