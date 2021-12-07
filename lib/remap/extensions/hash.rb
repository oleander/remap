# frozen_string_literal: true

module Remap
  module Extensions
    module Hash
      refine ::Hash do
        def formated
          JSON.neat_generate(self, sort: true, wrap: 40, aligned: true, around_colon: 1)
        end
      end
    end
  end
end
