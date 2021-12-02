# frozen_string_literal: true

class Vehicle < Remap::Base
  class Bicycle < Remap::Base
    contract do
      required(:gears)
      required(:brand)
    end

    define do
      to :bicycle
    end
  end

  class Car < Remap::Base
    contract do
      required(:hybrid)
      required(:fule)
    end

    define do
      to :car
    end
  end

  define do
    each do
      embed Bicycle | Car
    end
  end
end

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      Vehicle
    end

    let(:input) do
      [
        { gears: 3, brand: "Rose" },
        { hybrid: false, fule: "Petrol" }
      ]
    end

    let(:output) do
      be_a_success.and(
        have_attributes({
          result: [
            { bicycle: { gears: 3, brand: "Rose" } },
            { car: { hybrid: false, fule: "Petrol" } }
          ]
        }))
    end
  end
end
