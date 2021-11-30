# frozen_string_literal: true

module Remap
  # A static mapped value either represented by an option or a value
  class Static < Dry::Interface
    attribute? :backtrace, Types::Backtrace

    # Maps a static value to state
    #
    # @param state [State<T>]
    #
    # @return [State<Y>]
    #
    # @abstract
    def call(state)
      raise NotImplementedError, "#{self.class}#call not implemented"
    end
  end
end
