# frozen_string_literal: true

describe Remap::Base do
  class self::Mapper < Remap::Base
    option :date # <= Custom required value

    define do
      # Fixed values
      set :description, to: value("This is a description")

      # Semi-dynamic values
      set :date, to: option(:date)

      # Required rules
      get :friends do
        each do
          # Post processors
          map(:name, to: :id).adjust(&:upcase)

          # Field conditions
          get?(:age).if do |age|
            (30..50).cover?(age)
          end

          # Map to a finite set of values
          get(:phones) do
            each do
              map.enum do
                from "iPhone", to: "iOS"
                value "iOS", "Android"

                otherwise "Unknown"
              end
            end
          end
        end
      end

      class Linux < Remap::Base
        define do
          get :kernel
        end
      end

      class Windows < Remap::Base
        define do
          get :price
        end
      end

      # Composable mappers
      to :os do
        map :computer, :operating_system do
          embed Linux | Windows
        end
      end

      # Wrapping values in an array
      to :houses do
        wrap :array do
          map :house
        end
      end

      # Array selector (all)
      map :cars, all, :model, to: :cars
    end
  end

  subject { mapper.call(input, date: Date.today) }

  let(:mapper) { self.class::Mapper }

  let(:input) do
    {
      house: "100kvm",
      friends: [
        {
          name: "Lisa",
          age: 20,
          phones: ["iPhone"]
        }, {
          name: "Jane",
          age: 40,
          phones: ["Samsung"]
        }
      ],
      computer: {
        operating_system: {
          kernel: :latest
        }
      },
      cars: [
        {
          model: "Volvo"
        }, {
          model: "Tesla"
        }
      ]
    }
  end

  let(:output) do
    {
      friends: [
        {
          id: "LISA",
          phones: ["iOS"]
        }, {
          age: 40,
          id: "JANE",
          phones: ["Unknown"]
        }
      ],
      description: "This is a description",
      cars: ["Volvo", "Tesla"],
      houses: ["100kvm"],
      date: be_a(Date),
      os: {
        kernel: :latest
      }
    }
  end

  it { is_expected.to match(output) }
end
