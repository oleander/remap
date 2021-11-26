# Remap [![Main](https://github.com/oleander/remap/actions/workflows/main.yml/badge.svg)](https://github.com/oleander/remap/actions/workflows/main.yml)

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

      to(:car, map: :cars, first).then do |car|
        car.upcase
      end
    end
  end
end

result = Mapper.call({ people: { name: 'John', cars: ['Volvo'] } }, id: 'ABC-123')
pp result # => { key: 'ABC-123', nickname: 'John', car: 'VOLVO' }
```
