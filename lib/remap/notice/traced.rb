# frozen_string_literal: true

module Remap
  class Notice
    class Traced < Concrete
      attribute :backtrace, Types::Backtrace

      def traced(_)
        raise ArgumentError, "Traced notices are not supported"
      end

      def exception
        super
        # return super if backtrace.blank?

        # super.tap { _1.set_backtrace(backtrace.map(&:to_s)) }
      end
    end
  end
end
