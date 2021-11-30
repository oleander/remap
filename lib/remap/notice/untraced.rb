# frozen_string_literal: true

module Remap
  class Notice
    class Untraced < Concrete
      def traced(backtrace)
        Traced.call(**attributes, backtrace: backtrace)
      end
    end
  end
end
