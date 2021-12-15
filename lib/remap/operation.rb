# frozen_string_literal: true

module Remap
  using State::Extension
  using Extensions::Hash

  # Class interface for {Remap::Base} and instance interface for {Mapper}
  module Operation
    # Public interface for mappers
    #
    # @param input [Any] data to be mapped
    # @param options [Hash] mapper options
    #
    # @yield [Failure]
    #   when a non-critical error occurs
    # @yieldreturn T
    #
    # @return [Any, T]
    #   when request is a success
    # @raise [Remap::Error]
    #   when a fatal error occurs
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
