# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          to :people do
            map :names do
              each do
                map :id, to: :name
              end
            end
          end
        end
      end
    end

    let(:input) do
      { names: [{ id: "Skip" }, { id: "John" }] }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { people: [{ name: "Skip" }, { name: "John" }] }))
    end
  end
end
