# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define OpenStruct, strategy: :keyword do
          map
        end
      end
    end

    let(:input) do
      { name: "John", age: 30 }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: be_a(OpenStruct)))
    end
  end
end
