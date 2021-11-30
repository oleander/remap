# frozen_string_literal: true

module Remap
  class Static
    using State::Extension

    # Maps a mapper argument to a path
    #
    # @example Maps a mapper argument to a path
    #   class Mapper < Remap::Base
    #     option :name
    #
    #     define do
    #       set :nickname, to: option(:name)
    #     end
    #   end
    #
    #   Mapper.call(input, name: "John") # => { nickname: "John" }
    class Option < Concrete
      attribute :name, Symbol

      # Selects {#value} from {state#params}
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state.set(state.options.fetch(name))
      rescue KeyError
        raise ArgumentError, "Option [%s] not found in input [%p]" % [name, state.options]
      end
    end
  end
end
