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
        def call(state, &error)
          unless block_given?
            raise ArgumentError, "map.call(state, &error) requires a block"
          end

          super
        rescue Notice::Ignore => e
          e.undefined(state)
        end
      end
    end
  end
end
