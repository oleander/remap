# Re:map [![remap](https://github.com/oleander/remap/actions/workflows/main.yml/badge.svg?branch=development)](https://github.com/oleander/remap/actions/workflows/main.yml) [![Gem](https://img.shields.io/gem/v/remap)](https://rubygems.org/gems/remap) [![Maintainability](https://api.codeclimate.com/v1/badges/0c09721ad5a3b646a6d3/maintainability)](https://codeclimate.com/github/oleander/remap/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/0c09721ad5a3b646a6d3/test_coverage)](https://codeclimate.com/github/oleander/remap/test_coverage)

`Re:map`; an expressive and feature-rich data transformer written in Ruby 3.
It gives the developer the expressive power of JSONPath, without the hassle of using strings. Its compiler is written on top of an immutable, primitive data structure utilizing ruby's refinements & pattern matching capabilities – making it blazingly fast

- Overview
  - [API Documentation](http://oleander.io/remap)
  - [Quick start](#quick-start)
  - [Installation](#installation)
  - [Introduction](#introduction)
    - [Selectors](#selectors)
    - [Callbacks](#callbacks)
    - [Fixed & semi-fixed values](#fixed--semi-fixed-values)
    - [Type casting](#type-casting)
    - [Operators](#operators)
    - [Error handling](#error-handling)
    - [Constructors](#constructors)
    - [Schemas & rules](#schemas--rules)

## Quick start

``` ruby
require "remap"

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
        map(:name, to: :id).then do |value:|
          "#{value.upcase}!"
        end

        # Field conditions
        get?(:age).if do |age|
          (30..50).cover?(age)
        end

        # Map to a finite set of values
        get :phones do
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

    # Composable mappers
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

    # Embed mappers
    to :os do
      map :computer, :operating_system do
        embed Linux | Windows
      end
    end

    # Wrapping values in arrays
    to :houses do
      wrap :array do
        map :house
      end
    end

    # Nested paths ($.cars[*].model)
    map :cars, all, :model, to: :cars

    # Or using the #each iterator
    map :cars do
      each do
        map :model, to: :cars
      end
    end
  end
end
```

Input hash to be mapped

``` ruby
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
```

The expected mapped output

```ruby
output = {
  friends: [
    {
      id: "LISA!",
      phones: ["iOS"]
    }, {
      age: 40,
      id: "JANE!",
      phones: ["Unknown"]
    }
  ],
  description: "This is a description",
  cars: [{ owners: ["John"] }],
  houses: ["100kvm"],
  date: Date.today,
  os: {
    kernel: :latest
  }
}
```

Invoking the mapper with input and the `date` option

``` ruby
Mapper.call(input, date: Date.today) # => output
```

## Installation

Add `remap` to your `Gemfile`

``` ruby
# Use Github as source
source "https://rubygems.pkg.github.com/oleander" do
  gem "remap"
end

# Or Rubygems
gem "remap"
```

Then run `bundle install`

## Introduction

To create a mapper, inherit from `Remap::Base` and define your rules using `define`.

``` ruby
class Mapper < Remap::Base
  define do
    # rules goes here
  end
end

Mapper.call(input)
```

Or use `define` method directly on the Remap module

``` ruby
mapper = Remap.define do
  # rules goes here
end

mapper.call(input)
```

The easiest way to get started is using `map`.
`map` transform a value from one path to another.

``` ruby
class Mapper < Remap::Base
  define do
    map :name, to: :nickname
  end
end
```

To invoke the mapper, call `Mapper.call` with any input, i.e

``` ruby
Mapper.call({ name: "John" }) # => { nickname: "John" }
```

If the input data doesn't match the defined rule, an exception
will be thrown explaining what went wrong and where.
To prevent this, you can pass a block to `.call`.
The mapper will yield failures to the block instead of raising an error.

``` ruby
Mapper.call({ something: "value" }) do |failure|
  # ...
end
```

Use `map?`, `to?` and `get?` to map partial data structures.

``` ruby
class Mapper < Remap::Base
  define do
    map? :key1
    map? :key2
  end
end
```

If one of the two rules succeeds, the mapper returns a value.

``` ruby
Mapper.call({ key1: "value1" }) # ="value1"
Mapper.call({ key2: "value2" }) # ="value2"
```

If none of the rules succeeds, the mapper invokes the error block.

``` ruby
Mapper.call({ nope: "value" }) do |failure|
  # ...
end
```

Rules can be expressed in a variety of ways to best fit the
problem at hand.

The following rules yields the same output

``` ruby
# Flat map
map :person, :name, to: :first_name

# Flat to
to :first_name, map: [:person, :name]

# Nested map
map :person do
  map :name do
    to :first_name
  end
end

# Nested to
to :first_name do
  map :person do
    map :name
  end
end
```

To select a value *and* its path, use `get`, or `get?`.

``` ruby
class Mapper < Remap::Base
  define do
    get :person
  end
end

Mapper.call({ person: "John" }) # => { person: "John" }
```

Use `each` when iterating over arrays and hashes.

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

Mapper.call({ people: [{ name: "John" }, { name: "Jane" }] }) # => ["John", "Jane"]
```

### Selectors

Use the `all` selector as part of the path instead of `each`.

> `all` is similar to JSONPath’s `[*]` selector

``` ruby
class Mapper < Remap::Base
  define do
    map :people, all, :name
  end
end
```

`first` selects the first element in an array and `last` the last element.

> `first` & `last` is similar to JSONPath’s `[0]` `[-1]` selectors

``` ruby
class Mapper < Remap::Base
  define do
    map :people do
      map first, :name, to: :name
    end
  end
end

Mapper.call({ people: [{ name: "John" }] }) # => { name: "John" }
```

### Callbacks

Selected values can easily be processed before being returned using call-backs.

> See `Remap::Rule::Map` for more information

``` ruby
class Mapper < Remap::Base
  using Remap::Extensions::Hash

  define do
    map :people, all do
      # Pass a proc
      map(:name).then(&:upcase)

      # Or pass a block
      map(:name).then do |value:|
        value.upcase
      end

      # Manually skip a mapping
      map(:name).then do |&error|
        error["skip"]
      end

      # Add conditions
      map?(:name).if do |value:|
        value.include?("John")
      end

      map?(:name).if_not do |value:|
        value.include?("Lisa")
      end

      # Pending mappings
      map(:name).pending("I'll do this later")

      # Define rules for a finite set of values
      map(:name).enum do
        from "John", to: "Joe"
        value "Lisa", "Jane"
        otherwise "Unknown"
      end

      # Get is defined by the Remap::Extensions::Hash refinement
      # and allows for a path to be passed. If the path is missing,
      # the rule will be ignored in the case of `map?` and `map`
      # a detailed error message will be thrown with a detailed path
      map(:name).then do |value:|
        value.get(:a, :b)
      end
    end
  end
end
```

The callback context has access to the following values

* `value` current value
* `element` - defined by `each`
* `index` defined by `each`
* `key` defined by `to`, `map` and `each` on hashes
* `values` & `input` yields the mapper input
* `mapper` the current mapper

``` ruby
class Person < Remap::Base
  using Remap::Extensions::Enumerable

  define do
    get :person do
      get(:name)
      get?(:age).if do |values:|
        values.get(:person, :name) == "John"
      end
    end
  end
end
```

> See `Remap::State::Extension#execute` for more details

### Fixed & semi-fixed values

A mapper can require options using the `option` method.
An option can be referenced from within callbacks and via `set`.

``` ruby
class Mapper < Remap::Base
  option :code

  define do
    set :secret, to: option(:code)

    # Access {code} inside a callback
    map(:pin_code, to: :seed).then do |pin, code:|
      code**pin
    end
  end
end
```

The second argument to `Mapper.call` takes a hash and is used as options for the mapper.

``` ruby
Mapper.call({
  pin_code: 1234
}, code: 5678) # => { secret: 5678, seed: 3.2*10^10 }
```

`set` can also take a fixed value using the `value` method

``` ruby
class Mapper < Remap::Base
  define do
    set :api_key, to: value("ABC-123")
  end
end

Mapper.call(input) # => { api_key: "ABC-123" }
```

### Type casting

`wrap` allows output values to be type casts into an array.

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

Mapper.call({ name: "John" }) # ={ names: ["John"] }
```

### Operators

Mappers can be composed using the `|` (or), `&` (and) and `^` (xor) operators.
Composed mappers can then be embedded into other mappers using `embed`.

``` ruby
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
    required(:fuel)
  end

  define do
    to :car
  end
end

class Vehicle < Remap::Base
  define do
    each do
      embed Bicycle | Car
    end
  end
end

Vehicle.call([
  {
    gears: 3,
    brand: "Rose"
  }, {
    hybrid: false,
    fuel: "Petrol"
  }
]) # => [{ bicycle: { gears: 3, brand: "Rose" } }, { car: { hybrid: false, fuel: "Petrol" } }]
```

### Error handling

TODO

### Constructors

TODO

### Schemas & rules

TODO
