# frozen_string_literal: true

module Remap
  class Mapper
    using State::Extension

    module API
      # @return [Boolean]
      #
      # @abstract
      # @private
      def validate?
        raise NotImplementedError, "`validate?` is not implemented for #{self}"
      end

      # @param input [Any]
      # @param backtrace [Array<String>]
      # @param options [Hash]
      #
      # @yieldparam [Failure]
      # @yieldreturn [T]
      #
      # @return [Any, T]
      def call(input, backtrace: caller, **options, &error)
        unless block_given?
          return call(input, **options) do |failure|
            raise failure.exception(backtrace)
          end
        end

        s0 = State.call(input, options: options, mapper: self)._

        s1 = call!(s0) do |failure|
          return error[failure]
        end

        case s1
        in { value: value }
          value
        in { notices: [] }
          error[s1.failure("No data could be mapped")]
        in { notices: }
          error[Failure.new(failures: notices)]
        end
      end
    end
  end
end
