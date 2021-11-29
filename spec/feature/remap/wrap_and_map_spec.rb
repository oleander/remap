# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          to :people do
            wrap(:array) do
              map :person
            end
          end
        end
      end
    end

    let(:input) do
      { person: { name: "Loleander" } }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { people: [{ name: "Loleander" }] }))
    end
  end
end
