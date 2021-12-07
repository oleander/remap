# frozen_string_literal: true

describe Remap::Base do
  using Remap::Extensions::Enumerable
  using Remap::State::Extension

  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map.then { "#{value}!" }
        end
      end
    end

    let(:input) do
      "Hello"
    end

    let(:output) do
      be_a_success.and(have_attributes(result: "Hello!"))
    end
  end
end
