# frozen_string_literal: true

module Remap
  class Config < OpenStruct
    def initialize
      super(validation: false)
    end
  end
end
