# frozen_string_literal: true

describe Remap::Base do
  class self::Fast < described_class
    configuration do |c|
      c.validation = false
    end

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

  class self::Slow < self::Fast
    configuration do |c|
      c.validation = true
    end
  end

  describe "::call" do
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

    let(:fast) { self.class::Fast }
    let(:slow) { self.class::Slow }
    let(:date) { Date.today }
    let(:n) { 50 }

    it "runs the [Fast] mapper faster than the [Slow] mapper" do
      expect do
        n.times { fast.call(input, date: date) }
      end.to perform_faster_than {
        n.times { slow.call(input, date: date) }
      }
    end
  end
end
