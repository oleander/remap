# Re:map [![remap](https://github.com/oleander/remap/actions/workflows/main.yml/badge.svg?branch=development)](https://github.com/oleander/remap/actions/workflows/main.yml) ![Gem](https://img.shields.io/gem/v/remap) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/f07e265fc5184af584333f0bb62f3b47)](https://www.codacy.com/gh/oleander/remap/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=oleander/remap&amp;utm_campaign=Badge_Grade) [![Codacy Badge](https://app.codacy.com/project/badge/Coverage/f07e265fc5184af584333f0bb62f3b47)](https://www.codacy.com/gh/oleander/remap/dashboard?utm_source=github.com&utm_medium=referral&utm_content=oleander/remap&utm_campaign=Badge_Coverage)

> `Re:map`; an expressive and feature-complete data mapper designed as a domain-specific
> language using Ruby 3.0. `Re:map` gives the developer the expressive power of
> JSONPath, without the hassle of using strings. Its compiler is written on top
> of an immutable, primitive data structure utilizing ruby's refinements & pattern
> matching capabilities – making it blazingly fast

* [API Documentation](http://oleander.io/remap/)
* [Introduction](#introduction)
* [Installation](#installation)

``` ruby
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
      owners: [
        {
          name: "John"
        }
      ]
    }
  ]
}

output = {
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
  cars: [{ owners: ["John"] }],
  houses: ["100kvm"],
  date: be_a(Date),
  os: {
    kernel: :latest
  }
}

Mapper.call(input, date: Date.today) == output
```

## Installation

`gem install remap` then `require "remap"`

## Introduction

> To create a mapper, inherit from `Remap::Base` and define a `define` block.

``` ruby
class Mapper < Remap::Base
  define do
    # here goes your mapping rules
  end
end
```

> A *mapping rule* specifies how to map a value from one place to another

``` ruby
class Mapper < Remap::Base
  define do
    map :input, to: :output
  end
end
```

To invoke the mapper, call `Mapper.call` with some input data

``` ruby
Mapper.call({ input: "value" }) # => { output: "value" }
```

> If the input data doesn't match the defined rule, an exception will be thrown.
> To prevent this, pass a block to `.call` that will be called with a failure.

``` ruby
Mapper.call({ something: "value" }) do |failure|
  # ...
end
```

> The `failure` contains a detailed description of the error including the path to the problematic value.
> If the input data is incomplete, use `map?` to define an optional rule.
> It will be ignored whenever the path is missing.

``` ruby
class Mapper < Remap::Base
  define do
    map? :key1
    map? :key2
  end
end
```

> If one of the two rules matches the input, the mapper will return the value.

``` ruby
Mapper.call({ key1: "value1" }) # => "value1"
Mapper.call({ key2: "value2" }) # => "value2"
```

> If none if the rules matches, the mapper will raise an error or invoke the block

``` ruby
Mapper.call({ nope: "value" }) do |failure|
  # ...
end
```

> Rules can be expressed in a variety of ways to fit the implementation of the mapper.
> The following rules are all equal:

``` ruby
map :person, :name, to: :first_name

map :person do
  map :name do
    to :first_name
  end
end

to :first_name do
  map :person do
    map :name
  end
end
```

> To select a value with its path, use `get`

``` ruby
class Mapper < Remap::Base
  define do
    get :person
  end
end

Mapper.call({ person: "John" }) # => { person: "John" }
```

> Use `each` to iterate over an array of values

``` ruby
class Mapper < Remap::Base
  define do
    map :people do
      each do
        map :name
      end
    end
  end
end

Mapper.call({ people: [ { name: "John" }, { name: "Jane" } ] }) # => ["John", "Jane"]
```

> Alternatively, `all` can be used to express rules that applies to all values in an array.
> To accomplish this using the above input, do the following:

``` ruby
class Mapper < Remap::Base
  define do
    map :people, all, :name
  end
end
```

> Selected values can easily be processed before being mapped.
> To do this, append any of the methods defined in `Remap::Rule::Map`

``` ruby
class Mapper < Remap::Base
  using Extensions::Hash

  define do
    map :people, all do
      # Pass a proc
      map(:name).then(&:upcase)

      # Or pass a block
      map(:name).then do
        value.upcase
      end

      # Manually skip a mapping using skip!
      map(:name).then do
        skip!
      end

      # Add conditions
      map?(:name).if do
        value.include?("John")
      end

      map?(:name).if_not do
        value.include?("Lisa")
      end

      # Pending mappings
      map(:name).pending("I'll do this later")

      # Define rules for a finite set of values
      map(:name).enum do
        from "John", to "Joe"
        value "Lisa", "Jane"
        otherwise "Unknown"
      end

      # Get is defined by the Remap::Extensions::Hash refinement
      # and allows for a path to be passed. If the path is missing,
      # the rule will be ignored in the case of `map?` and `map`
      # a detailed error message will be thrown with a detailed path
      map(:name).then do
        value.get(:a, :b)
      end
    end
  end
end
```

> The block scope gives access to some useful values

* `value` current value
* `element` - defined by `each`
* `index` defined by `each`
* `key` defined by `to`, `map` and `each` on hashes
* `values` & `input` yields the mapper input
* `mapper` the current mapper

> The complete set of values are defined by `Remap::State::Extension#execute`.

### Fixed values

> A mapper can define required options using `option`.
> These values can be referenced any where in the mapper
> An can be set to a fixed path using `set`

``` ruby
class Mapper < Remap::Base
  option :code

  define do
    set :secret, to: option(:code)

    # Access {code} inside a callback
    map(:pin_code, to: :seed).then do |pin|
      code ** pin
    end
  end
end
```

The second argument to `Mapper.call` takes a hash, used to populate the mapper.

``` ruby
Mapper.call({ pin_code: 1234}, code: 5678) # => { secret: 5678, seed: 3.2*10^10 }
```

### Fixed values

> `set` also accepts a fixed value in combination with `value`, i.e

``` ruby
class Mapper < Remap::Base
  define do
    set :api_key, to: value("ABC-123")
  end
end

Mapper.call({}) # => { api_key: "ABC-123" }
```

### Wrap output

> Wraps the mapped value in an array

``` ruby
class Mapper < Remap::Base
  define do
    to :names do
      wrap(:array) do
        map :name
      end
    end
  end
end

Mapper.call({ name: "John" }) # => { names: ["John"] }
```

### Combine mappers using operators

> Mappers can be combined using the logical operators `|`, `&` and `^`

``` ruby
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

output = Vehicle.call([
  { gears: 3, brand: "Rose" },
  { hybrid: false, fule: "Petrol" }
])
```

> Supported operators are `|`, `&` and `^`
