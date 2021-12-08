# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          map? :ok1, :ok2, :ok3, :missing
          map? :ok1, :missing
          map :ok1
        end
      end
    end

    let(:input) do
      { ok1: { key: "value" } }
    end

    let(:output) do
      { key: "value" }
    end
  end
end
