# frozen_string_literal: true

module Remap
  class Notice
    using Extensions::Hash
    using State::Extension

    class Error < Remap::Error
      extend Dry::Initializer

      delegate_missing_to :notice
      delegate :inspect, :to_s, to: :notice
      option :notice, type: Types.Instance(Notice)

      def inspect
        "#<%s %s>" % [self.class, to_hash.formatted]
      end

      def undefined(state)
        state.set(notice: notice).except(:value)
      end

      def failure(state)
        Failure.new(failures: [notice], notices: state.fetch(:notices))
      end

      def traced(backtrace)
        e = Traced.new(notice: notice)
        e.set_backtrace(backtrace)
        e
      end
    end

    class Traced < Error
    end
  end
end
