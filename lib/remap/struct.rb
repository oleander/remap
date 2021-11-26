# frozen_string_literal: true

module Remap
  class Struct < Dry::Struct
    schema schema.strict(true)
  end
end
