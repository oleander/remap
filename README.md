# Remap [![Main](https://github.com/oleander/remap/actions/workflows/main.yml/badge.svg)](https://github.com/oleander/remap/actions/workflows/main.yml)

> `Re:map`; an expressive and feature-complete data mapper design as a domain-specific language in Ruby 3.0

``` ruby
class Mapper < Remap::Base
  option :key # <= Custom required value

  # Optional requirements
  contract do
    required(:people).hash do
      required(:name).filled
      required(:cars).array
    end
  end

  define do
    # Fixed values
    set :id, to: value("<VALID>")

    # Semi-dynamic values
    set :key, to: option(:key)

    # Required rules
    map :people do
      # Post processors
      map(:name).adjust(&:upcase)

      # Field conditions
      map(:age).if do |age|
        age > 50
      end

      # Map to a finite set of values
      map(:phones).enum do
        from "iPhone", to: "iOS"
        value "iOS", "Android"

        otherwise "Unknown"
      end
    end

    # Optional rule
    get? :countries do
      get :name
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
      embed Linux | Windows
    end

    map :cars do
      each do
        # Dig deep into a nested value
        map :owners, all do
          # Wrap output values
          wrap :array do
            map :name, :names
          end
        end
      end
    end
  end
end
```

## Examples

### Map a value from one path to another

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
output = Mapper.call({ person: { name: 'John' } })
output.result # => { nickname: 'John' }
```

### Select all elements in an array

> Similar to JSONPath's `[*] operator and allows paths to dig into nested arrays and hashes

``` ruby
class Mapper < Remap::Base
  define do
    map [all, :name]
  end
end

output = Mapper.call([{ name: "John" }, { name: "Jane" }])
output.result # => ["John", "Jane"]
```

### Fixed values predefined in the mapper

> A mapper instance can hold a set of pre-defined options. Use the `option` method to define a mappers requirement

``` ruby
class Mapper < Remap::Base
  option :name

  define do
    set [:person, :name], to: option(:name)
  end
end

output = Mapper.call({}, name: "John")
output.result # => { person: { name: "John" } }
```

### Fixed value defined in the mapper

> Allows a fixed value to be merged into the final data structure

``` ruby
class Mapper < Remap::Base
  define do
    set [:api_key], to: value("ABC-123")
  end
end

output = Mapper.call({})
output.result # => { api_key: "ABC-123" }
```

### Skip mapping rule unless some condition is fulfilled

> `map` and `to` allows the user to define post-processors and conditions for selected values

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

output = Mapper.call(["A", "B", "C"])
output.result # => ["A", "C"]
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

output = Mapper.call(["A", "B", "C"])
output.result # => ["B"]
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

output = Mapper.call({
  countries: [
    { name: "SWE" },
    { name: "DE" },
    { name: "USA" },
    { name: "IT" }
  ]
})

output.result # => { names: ["SWE", "DE", "US", "OTHER"] }
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

output = Mapper.call({ workplace: "Apple", name: "John" })
output.result # => { nickname: "John" }
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

output = Mapper.call({ people: [{ name: "John" }] })
output.result # => { names: ["John"] }
```

> The scope gives access to a few handly values

- `value` current value
- `element` - defined by `each`
- `index` defined by `each`
- `key` defined by `to`, `map` and `each` on hashes
- `values` & `input` yields the mapper input
- `mapper` the current mapper

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

output = Mapper.call({ people: [{ name: "John" }] })
output.result # => [{ name: "John" }]
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

output = Mapper.call({ people: [{ name: "John" }] })
output.result # => [0]
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

output = Mapper.call("Hello")
output.result # => "Hello!"
```

### Select element at index

> Similar to JSONPath's `[n]` selector

``` ruby
class Mapper < Remap::Base
  define do
    map :people, at(0), :name
  end
end

output = Mapper.call({ people: [{ name: "John" }, { name: "Jane"}] })
output.result # => "John"
```

> or `first`

``` ruby
class Mapper < Remap::Base
  define do
    map :people, first, :name
  end
end

output = Mapper.call({ people: [{ name: "John" }, { name: "Jane"}] })
output.result # => "John"
```

> or `last`

``` ruby
class Mapper < Remap::Base
  define do
    map :people, last, :name
  end
end

output = Mapper.call({ people: [{ name: "John" }, { name: "Jane"}] })
output.result # => "Jane"
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

output = Mapper.call({ name: "John" })
output.result # => { names: ["John"] }
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

> Use the optional mapping rules `to?` and `map?` to define optional rules. By default, `to` and `map` cause the mapper to fail when a path cannot be found. The optional rules will just be ignored. This is perfect during development as it allows for partial inputs without breaking the mapper

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
