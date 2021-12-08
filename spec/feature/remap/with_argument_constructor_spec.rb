# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define ::Struct.new(:name, :age) do
          map
        end
      end
    end

    let(:input) do
      ["John", 60]
    end

    let(:output) do
      be_a(::Struct)
    end
  end
end
