# frozen_string_literal: true

module Remap
  class Selector
    using State::Extension

    # Selects value at given index
    #
    # @example Select the value at index 1 from a array
    #   state = Remap::State.call([:one, :two, :tree])
    #   index = Remap::Selector::Index.new(1)
    #
    #   result = index.call(state) do |element|
    #     value = element.fetch(:value)
    #     element.merge(value: value.upcase)
    #   end
    #
    #   result.fetch(:value) # => :TWO
    class Index < Unit
      # @return [Integer]
      attribute :index, Integer

      requirement Types::Array

      # Selects the {#index}th element from state and passes it to block
      #
      # @param outer_state [State<Array<T>>]
      #
      # @yieldparam [State<T>]
      # @yieldreturn [State<U>]
      #
      # @return [State<U>]
      def call(state, &block)
        unless block_given?
          raise ArgumentError, "The index selector requires an iteration block"
        end

        state.bind(index: index) do |array, s|
          requirement[array] do
            s.fatal!("Expected an array")
          end

          element = array.fetch(index) do
            s.ignore!("Index %s not found", index)
          end

          state.set(element, index: index).then(&block)
        end
      end
    end
  end
end
