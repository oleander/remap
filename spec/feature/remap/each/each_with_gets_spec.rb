# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          each do
            get :name
            get :age
          end
        end
      end
    end

    let(:input) do
      [
        {
          name: "Linus",
          age: 50
        }, {
          name: "John",
          age: 100
        }
      ]
    end

    let(:output) do
      be_a_success.and(have_attributes(result: input))
    end
  end
end
