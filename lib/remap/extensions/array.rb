# frozen_string_literal: true

module Remap
  module Extensions
    module Array
      refine ::Array do
        using Object

        # @return [Array<Hash>]
        def to_hash
          map(&:to_hash)
        end
      end
    end
  end
end
