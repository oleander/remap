# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map(:constants) do
            each do
              map.enum do
                value "A", "B"
                from "C", to: "D"
                otherwise "E"
              end
            end
          end
        end
      end
    end

    let(:input) do
      { constants: ["A", "B", "C", "D", "E", "F"] }
    end

    let(:output) do
      [
        "A", "B", "D", "D", "E",
        "E"
      ]
    end
  end
end
