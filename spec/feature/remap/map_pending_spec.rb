# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map(:age).pending
          map(:name, to: :name)
        end
      end
    end

    let(:input) do
      { name: "John" }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { name: "John" }, problems: be_present))
    end
  end
end
