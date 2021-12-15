# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Optional < Concrete
        # Represents an optional mapping rule
        # When the mapping fails, the value is ignored
        #
        # @example Map [:name] to [:nickname]
        #   map = Map::Optional.call({
        #     path: {
        #       input: [:name],
        #       output: [:nickname]
        #     }
        #   })
        #
        #   state = Remap::State.call({
        #     name: "John"
        #   })
        #
        #   output = map.call(state) do |failure|
        #     raise failure.exeception
        #   end
        #
        #   output.fetch(:value) # => { nickname: "John" }
        #
        # @param state [State]
        #
        # @return [State]
        def call(state)
          catch { super(state.set(id: _1)).except(:id) }
        end
      end
    end
  end
end
