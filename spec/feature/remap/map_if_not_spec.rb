# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          each do
            map?.if_not do |value|
              value.include?("A")
            end
          end
        end
      end
    end

    let(:input) { ["A", "B", "C"] }

    let(:output) do
      ["B", "C"]
    end
  end
end
