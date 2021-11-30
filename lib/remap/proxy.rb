# frozen_string_literal: true

module Remap
  # Used by {Enum} & {Compiler} to create a clean context
  class Proxy < ActiveSupport::ProxyObject
    def self.const_missing(name)
      ::Object.const_get(name)
    end

    include Dry::Core::Constants
    extend Dry::Initializer

    def tap(&block)
      block[self]
      self
    end
  end
end
