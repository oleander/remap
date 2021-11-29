# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          to :person do
            map :people, last
          end
        end
      end
    end

    let(:input) do
      { people: [{ name: "Skip" }, { name: "John" }] }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { person: { name: "John" } }))
    end
  end
end
