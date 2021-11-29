# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map [:people, at(1), :name] do
            to :name
          end
        end
      end
    end

    let(:input) do
      { people: [{ name: "Skip" }, { name: "John" }] }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { name: "John" }))
    end
  end
end
