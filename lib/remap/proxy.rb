# frozen_string_literal: true

module Remap
  class Proxy < ActiveSupport::ProxyObject
    def self.const_missing(name)
      ::Object.const_get(name)
    end

    include Dry::Core::Constants
    extend Dry::Initializer
    include Kernel

    # See Object#tap
    def tap(&block)
      block[self]
      self
    end
  end
end
