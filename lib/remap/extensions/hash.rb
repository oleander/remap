# frozen_string_literal: true

module Remap
  module Extensions
    module Hash
      refine ::Hash do
        def formatted
          JSON.neat_generate(compact_blank, sort: true, wrap: 40, aligned: true, around_colon: 1)
        end
      end
    end
  end
end
