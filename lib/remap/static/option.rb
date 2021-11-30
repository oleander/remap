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
    #   Mapper.call({}, name: "John").result # => { nickname: "John" }
    class Option < Concrete
      # @return [Symbol]
      attribute :name, Symbol

      # Selects {#name} from state
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state.set(state.options.fetch(name))
      rescue KeyError
        halt("Option [%s] not found in input [%p]", name, state.options)
      end
    end
  end
end
