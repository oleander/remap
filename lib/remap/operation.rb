# frozen_string_literal: true

module Remap
  using State::Extension

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

      s0 = State.call(input, options: options, mapper: self)

      s1 = call!(s0) do |failure|
        return error[failure]
      end

      s1.fetch(:value) do
        notice = s1.notice("No mapped data")

        Failure.new(notices: s1.notices, failures: [notice]).then(&error)
      end
    end
  end
end
