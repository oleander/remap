# frozen_string_literal: true

module Remap
  # @abstract
  class Mapper < Struct
    extend Operations
    include Operations
  end
end
