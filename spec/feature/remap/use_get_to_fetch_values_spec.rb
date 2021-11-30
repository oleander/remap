# frozen_string_literal: true

describe Remap::Base do
  using Remap::State::Extensions::Enumerable
  using Remap::State::Extension

  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          to(:exists).then do
            value.get(:a, :b, 1)
          end

          to?(:missing).then do
            value.get(:a, :e, 1)
          end
        end
      end
    end

    let(:input) do
      { a: { b: [1, 2, 3] } }
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { exists: 2 }))
    end
  end
end
