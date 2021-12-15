# frozen_string_literal: true

module Remap
  module Extensions
    module Array
      refine ::Array do
        def to_hash
          map(&:to_hash)
        end
      end
    end
  end
end
