# frozen_string_literal: true

module Remap
  # Represents a sequence of keys and selects or maps a value given a path
  class Path < Dry::Interface
    attribute :segments, Types::Array

    delegate :>>, to: :to_proc

    # @return [State]
    #
    # @abstract
    def call(state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end

    # @return [Proc]
    def to_proc
      method(:call).to_proc
    end
  end
end
