# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          get(:items) do
            each do
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
      end
    end

    let(:input) do
      {
        items: [
          {
            items: ["A", "B", "C"]
          }
        ]
      }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { items: [{ items: ["B", "B", "C"] }] }))
    end
  end
end
