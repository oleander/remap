# frozen_string_literal: true

module Remap
  class Static < Dry::Interface
    # Maps a static value to {state}
    #
    # @param state [State<T>]
    #
    # @return [State<Y>]
    #
    # @abstract
    def call(_state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end
  end
end
