# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
        define do
          to :drive do
            map :people do
              each do
                map?(:name).if do
                  element.fetch(:age) > 18
                end
              end
            end
          end

          to :retire do
            map :people do
              each do
                map?(:name).if_not do
                  element.fetch(:age) < 65
                end
              end
            end
          end
        end
      end
    end

    let(:input) do
      {
        people: [
          { name: "Skip", age: 18 },
          { name: "John", age: 19 },
          { name: "Jane", age: 20 },
          { name: "Jack", age: 65 }
        ]
      }
    end

    let(:output) do
      {
        drive: ["John", "Jane", "Jack"],
        retire: [
          "Jack"
        ]
      }
    end
  end
end
