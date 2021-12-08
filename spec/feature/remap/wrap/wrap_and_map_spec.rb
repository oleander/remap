# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          wrap :array do
            map :item
          end
        end
      end
    end

    let(:input) do
      { item: "value" }
    end

    let(:output) do
      ["value"]
    end
  end
end
