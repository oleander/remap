# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          get(:items) do
            each do
              map.enum do
                from "A", to: "B"
                otherwise "C"
              end
            end
          end
        end
      end
    end

    let(:input) do
      { items: ["A", "B", "C"] }
    end

    let(:output) do
      { items: ["B", "B", "C"] }
    end
  end
end
