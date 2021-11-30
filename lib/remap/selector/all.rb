# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects all elements from a state
    #
    # @example Select all elements
    #   class Mapper < Remap::Base
    #     define do
    #       map [all, :name]
    #     end
    #   end
    #
    #   output = Mapper.call([{ name: "John" }, { name: "Jane" }])
    #   output.result # => ["John", "Jane"]
    class All < Concrete
      requirement Types::Enumerable

      # Iterates over state and passes each value to block
      #
      # @param state [State<Enumerable<T>>]
      #
      # @yieldparam [State<T>]
      # @yieldreturn [State<U>]
      #
      # @return [State<U>]
      def call(state, &block)
        unless block
          return call(state, &:itself)
        end

        state.bind(quantifier: "*") do |enumerable, inner_state, &error|
          requirement[enumerable] do
            return error["Expected an enumeration"]
          end

          inner_state.map(&block)
        end
      end
    end
  end
end
