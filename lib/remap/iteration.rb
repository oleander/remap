# frozen_string_literal: true

module Remap
  class Iteration < Dry::Interface
    attribute :state, Types::State
    attribute :value, Types::Any

    # Maps every element in {#value} to {#block}
    #
    # @abstract
    #
    # @yieldparam element [V]
    # @yieldparam key [K, Integer]
    # @yieldreturn [Array<V>, Hash<V, K>]
    #
    # @return [Array<V>, Hash<V, K>]

    order :Hash, :Array, :Other
  end
end
