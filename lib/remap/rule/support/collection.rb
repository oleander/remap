# frozen_string_literal: true

module Remap
  class Rule
    class Collection < Dry::Interface
      def to_proc
        method(:call).to_proc
      end
    end
  end
end
