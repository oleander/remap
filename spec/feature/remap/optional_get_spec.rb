# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map :person do
            get :age
            get? :name
          end
        end
      end
    end

    let(:input) do
      { person: { age: 42 } }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { age: 42 }))
    end
  end
end
