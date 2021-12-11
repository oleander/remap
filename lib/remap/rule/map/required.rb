# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Required < Concrete
        attribute :backtrace, Types::Backtrace

        # Represents a required mapping rule
        # When it fails, the entire mapping is marked as failed
        #
        # @example Map [:name] to [:nickname]
        #   map = Map::Required.call({
        #     backtrace: caller,
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
        #     # ...
        #   end
        #
        #   output.fetch(:value) # => { nickname: "John" }
        #
        # @param state [State]
        #
        # @return [State]
        def call(state, &error)
          unless block_given?
            raise ArgumentError, "Required.call(state, &error) requires a block"
          end

          super
        rescue Notice::Ignore => e
          error[e.failure(state)]
        end
      end
    end
  end
end
