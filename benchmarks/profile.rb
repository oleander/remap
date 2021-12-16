# frozen_string_literal: true

require "bundler/setup"
Bundler.require
require "remap"
require "stackprof"
require "benchmark/ips"

class Mapper < Remap::Base
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

input = {
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

def path(name)
  Pathname(__dir__).join("..", "tmp/#{name}.dump").to_s
end

options = { date: Date.today }
state = Remap::State.call(input, mapper: Mapper, options: options)
mapper = Mapper.new(options)

runner = -> do
  10.times do
    mapper.call(state)
  end
end

StackProf.run(raw: true, out: path("wall"), mode: :wall, &runner)
StackProf.run(raw: true, out: path("object"), mode: :object, &runner)
StackProf.run(raw: true, out: path("cpu"), mode: :cpu, &runner)
