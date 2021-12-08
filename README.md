# Re:map [![Main](https://github.com/oleander/remap/actions/workflows/main.yml/badge.svg)](https://github.com/oleander/remap/actions/workflows/main.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/f07e265fc5184af584333f0bb62f3b47)](https://www.codacy.com/gh/oleander/remap/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=oleander/remap&amp;utm_campaign=Badge_Grade) [![Codacy Badge](https://app.codacy.com/project/badge/Coverage/f07e265fc5184af584333f0bb62f3b47)](https://www.codacy.com/gh/oleander/remap/dashboard?utm_source=github.com&utm_medium=referral&utm_content=oleander/remap&utm_campaign=Badge_Coverage)

> `Re:map`; an expressive and feature-complete data mapper designed as a domain-specific
> language using Ruby 3.0. `Re:map` gives the developer the expressive power of
> JSONPath, without the hassle of using strings. Its compiler is written on top
> of an immutable, primitive data structure utilizing Rubys refinements & pattern
> matching capabilities – making it blazingly fast

* [Documentation](http://oleander.io/remap/)
* [Examples](#examples)
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

    to :houses do
      # Value wrapper
      wrap :array do
        map :house
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

    get :cars do
      each do
        # Dig deep into a nested value
        get :owners do
          each do
            map :name
          end
        end
      end
    end
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

## Examples

### Map a value

> from path `[:person, :name]` to `[:nickname]`

``` ruby
class Mapper < Remap::Base
  define do
    map :person, :name, to: :nickname
  end
end
```

> `map` and `to` can be flipped around

``` ruby
class Mapper < Remap::Base
  define do
    to :nickname, map: :person, :name
  end
end
```

> as well as deeply nested for improved readability

``` ruby
class Mapper < Remap::Base
  define do
    to :nickname do
      map :person do
        map :name
      end
    end
  end
end
```

> the rules can be mixed to fix the data structure

``` ruby
class Mapper < Remap::Base
  define do
    map :person do
      map :name do
        to :nickname
      end
    end
  end
end
```

> to invoke do the following

``` ruby
Mapper.call({ person: { name: 'John' } }) # => { nickname: 'John' }
```

### Select all elements in an array

> Similar to JSONPath's `[*]` operator and allows
> paths to dig into nested arrays and hashes

``` ruby
class Mapper < Remap::Base
  define do
    map [all, :name]
  end
end

Mapper.call([{ name: "John" }, { name: "Jane" }]) # => ["John", "Jane"]
```

### Fixed values predefined in the mapper

> A mapper instance can hold a set of pre-defined options.
> Use the `option` method to define a mappers requirement

``` ruby
class Mapper < Remap::Base
  option :name

  define do
    set [:person, :name], to: option(:name)
  end
end

Mapper.call({}, name: "John") # => { person: { name: "John" } }
```

### Fixed value defined in the mapper

> Allows a fixed value to be merged into the final data structure

``` ruby
class Mapper < Remap::Base
  define do
    set [:api_key], to: value("ABC-123")
  end
end

Mapper.call({}) # => { api_key: "ABC-123" }
```

### Skip mapping rule unless some condition is fulfilled

> `map` and `to` allows the user to define post-processors
> and conditions for selected values

``` ruby
class Mapper < Remap::Base
  define do
    each do
      map.if_not do
        value.include?("B")
      end
    end
  end
end

Mapper.call(["A", "B", "C"]) # => ["A", "C"]
```

> or use `if` to reverse the selection

``` ruby
class Mapper < Remap::Base
  define do
    each do
      map.if do
        value.include?("B")
      end
    end
  end
end

Mapper.call(["A", "B", "C"]) # => ["B"]
```

### Map to a fixed set of values

> `enum` lets the mapper define a finite set of values for a particular path

``` ruby
class Mapper < Remap::Base
  define do
    to :names do
      map(:countries, all, :name).enum do
        from "USA", to: "US"
        value "SWE", "DE"
        otherwise "OTHER"
      end
    end
  end
end

Mapper.call({
  countries: [
    { name: "SWE" },
    { name: "DE" },
    { name: "USA" },
    { name: "IT" }
  ]
}) # => { names: ["SWE", "DE", "US", "OTHER"] }
```

### Pending mapping

> Use `pending` on rules that has yet to be defined

``` ruby
class Mapper < Remap::Base
  define do
    map(:workplace, to: :job).pending
    map(:name, to: :nickname)
  end
end

Mapper.call({ workplace: "Apple", name: "John" }) # => { nickname: "John" }
```

### Iterate over an enumerable

> `each` works similar to `all` and allows for arrays and hashes to be mixed

``` ruby
class Mapper < Remap::Base
  define do
    map :people, to: :names do
      each do
        map :name
      end
    end
  end
end

Mapper.call({ people: [{ name: "John" }] }) # => { names: ["John"] }
```

> The scope gives access to a few handly values

* `value` current value
* `element` - defined by `each`
* `index` defined by `each`
* `key` defined by `to`, `map` and `each` on hashes
* `values` & `input` yields the mapper input
* `mapper` the current mapper

``` ruby
class Mapper < Remap::Base
  define do
    map :people, to: :names do
      each do
        map(:name).then do
          element
        end
      end
    end
  end
end

Mapper.call({ people: [{ name: "John" }] }) # => [{ name: "John" }]
```

> or `index` to get access to `each`'s index

``` ruby
class Mapper < Remap::Base
  define do
    map :people, to: :names do
      each do
        map(:name).then do
          index
        end
      end
    end
  end
end

Mapper.call({ people: [{ name: "John" }] }) # => [0]
```

### Post-process a mapped value

``` ruby
class Mapper < Remap::Base
  define do
    map.adjust do
      "#{value}!"
    end
  end
end

Mapper.call("Hello") # => "Hello!"
```

### Select element at index

> Similar to JSONPath's `[n]` selector

``` ruby
class Mapper < Remap::Base
  define do
    map :people, at(0), :name
  end
end

Mapper.call({ people: [{ name: "John" }, { name: "Jane"}] }) # => "John"
```

> or `first`

``` ruby
class Mapper < Remap::Base
  define do
    map :people, first, :name
  end
end

Mapper.call({ people: [{ name: "John" }, { name: "Jane"}] }) # => "John"
```

> or `last`

``` ruby
class Mapper < Remap::Base
  define do
    map :people, last, :name
  end
end

Mapper.call({ people: [{ name: "John" }, { name: "Jane"}] }) # => "Jane"
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

### Manually skip a mapping

> Use `skip!` to manually skip a field

``` ruby
class Mapper < Remap::Base
  define do
    map.then do
      skip!("I'll do this later")
    end
  end
end
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

### Optional mappings

> Use the optional mapping rules `to?` and `map?` to define optional rules.
> By default, `to` and `map` cause the mapper to fail when a path cannot be found.
> The optional rules will just be ignored. This is perfect during development as
> it allows for partial inputs without breaking the mapper

``` ruby
class Person < Mapper::Base
  define do
    get :person do
      get :name # Required
      get? :age # Optional
    end
  end
end

# OK!
Person.call({
  person: {
    name: "Linus"
  }
})

# OK!
Person.call({
  person: {
    name: "Linus",
    age: 30
  }
})

# NOT OK
Person.call({
  person: {
    age: 30
  }
})
```
