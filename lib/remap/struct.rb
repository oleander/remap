# frozen_string_literal: true

module Remap
  # Base class used throughout the library
  class Struct < Dry::Struct
    schema schema.strict(true)
  end
end
