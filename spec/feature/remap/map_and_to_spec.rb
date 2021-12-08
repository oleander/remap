# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          to :person, :name do
            map :human do
              map :nickname
            end
          end
        end
      end
    end

    let(:input) do
      { human: { nickname: "Loleander" } }
    end

    let(:output) do
      { person: { name: "Loleander" } }
    end
  end
end
