module Remap
  class Path < Dry::Interface
    attribute :segments, Types::Array

    # @return [State]
    def call(state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end

    # @return [Proc]
    def to_proc
      method(:call).to_proc
    end
  end
end
