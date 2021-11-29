# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          to :person do
            map :people, first
          end
        end
      end
    end

    let(:input) do
      { people: [{ name: "John" }, { name: "Skip" }] }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { person: { name: "John" } }))
    end
  end
end
