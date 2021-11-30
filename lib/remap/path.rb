# frozen_string_literal: true

module Remap
  class Path < Dry::Interface
    attribute :segments, Types::Array

    delegate :>>, to: :to_proc

    # @return [State]
    def call(_state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end

    # @return [Proc]
    def to_proc
      method(:call).to_proc
    end
  end
end
