# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map?(:a, :b, :c, :missing).then { skip! }
        end
      end
    end

    let(:input) do
      { a: { b: { c: 1 } } }
    end

    let(:output) do
      be_a_failure.and(have_attributes(failures: be_present))
    end
  end
end
