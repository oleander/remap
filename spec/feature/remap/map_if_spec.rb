# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          each do
            map?.if do
              value.include?("A")
            end
          end
        end
      end
    end

    let(:input) { ["A", "B", "C"] }

    let(:output) do
      be_a_success.and(have_attributes(result: ["A"]))
    end
  end
end
