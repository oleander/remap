# frozen_string_literal: true

module Remap
  class Notice
    class Traced < Concrete
      attribute :backtrace, [String]

      def traced(_)
        raise ArgumentError, "Traced notices are not supported"
      end

      def exception
        return super if backtrace.blank?

        super.tap { _1.set_backtrace(backtrace) }
      end
    end
  end
end
