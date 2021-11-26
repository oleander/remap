# frozen_string_literal: true

module Remap
  module State
    module Types
      include Dry.Types()

      Key = String | Symbol | Integer
    end
  end
end
