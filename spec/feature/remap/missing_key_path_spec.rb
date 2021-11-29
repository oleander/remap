# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          set :good, to: value("<VALUE>")

          map :missing1, to: []
          to [], map: :missing2
        end
      end
    end

    let(:input) do
      {}
    end

    let(:output) do
      be_a_success.and(have_attributes(result: { good: "<VALUE>" }))
    end
  end
end
