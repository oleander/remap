# frozen_string_literal: true

require "dry/core/class_builder"

module Remap
  module ClassInterface
    # @see Remap::Base.define
    def define(...)
      Dry::Core::ClassBuilder.new(name: "Mapper", parent: Base).call do |klass|
        klass.define(...)
      end
    end
  end
end
