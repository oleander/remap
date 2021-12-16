# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Optional < Required
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
        # @see Map#call
        def call(state)
          catch_ignored { super(state.set(id: _1)).remove_id }
        end
      end
    end
  end
end
