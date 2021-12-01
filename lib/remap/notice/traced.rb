# frozen_string_literal: true

module Remap
  class Notice
    class Traced < Concrete
      attribute? :backtrace, Types::Backtrace, default: EMPTY_ARRAY

      def traced(backtrace)
        Notice.call(**attributes, backtrace: backtrace)
      end

      def exception
        return super if backtrace.blank?

        super.tap { _1.set_backtrace(backtrace.map(&:to_s)) }
      end
    end
  end
end
