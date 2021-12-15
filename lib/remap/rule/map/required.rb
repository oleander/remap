# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Required < Concrete
        attribute :backtrace, Types::Backtrace

        # TODO: Remove
      end
    end
  end
end
