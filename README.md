# Remap [![Main](https://github.com/oleander/remap/actions/workflows/rspec.yml/badge.svg)](https://github.com/oleander/remap/actions/workflows/rspec.yml)

``` ruby
class Mapper < Remap::Base
  option :id

  contract do
    required(:people).hash do
      required(:name).filled
      required(:cars).array
    end
  end

  define do
    set :key, to: option(:id)

    map :people do
      map :name, to: :nickname

      to(:car, map: :cars, first).then(&:upcase)
    end
  end
end

result = Mapper.call({ people: { name: 'John', cars: ['Volvo'] } }, id: 'ABC-123')
pp result # => { key: 'ABC-123', nickname: 'John', car: 'VOLVO' }
```

## Examples

### Map a value

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

> and deeply nested

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

> which works both ways

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

> Similar to JSONPath's `[*] operator

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

``` ruby
class Mapper < Remap::Base
  define do
    set [:api_key], to: value("ABC-123")
  end
end

output = Mapper.call({})
output.result # => { api_key: "ABC-123" }
```
### Skip mapping rule, unless some condition is fulfilled

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

> or use `if` to reverse

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

### Enum mapping

``` ruby
class Mapper < Remap::Base
  define do
    map(:a, :b).enum do
      value "A", "B"
    end
  end
end

Mapper.call({ a: { b: "A" } }).result # => "A"
Mapper.call({ a: { b: "B" } }).result # => "B"
```

### Pending mapping

``` ruby
class Mapper < Remap::Base
  define do
    map(:a, :b).pending
  end
end

Mapper.call({ a: { b: "A" } }).problems.count # => 1
```

### Iterate over an enumerable

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

> `element`, `index` and `key` can be accessed in the block

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

### Wrap output result in an array

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
