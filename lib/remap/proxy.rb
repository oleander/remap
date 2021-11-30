# frozen_string_literal: true

module Remap
  class Proxy < ActiveSupport::ProxyObject
    def self.const_missing(name)
      ::Object.const_get(name)
    end

    extend Dry::Initializer
  end
end
