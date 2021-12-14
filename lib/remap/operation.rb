# frozen_string_literal: true

module Remap
  using State::Extension

  # Class interface for {Remap::Base} and instance interface for {Mapper}
  module Operation
    # Public interface for mappers
    #
    # @param input [Any] Data to be mapped
    # @param options [Hash] Mapper arguments
    #
    # @yield [Failure] if mapper fails
    #
    # @return [Success] if mapper succeeds
    def call(input, **options, &error)
      unless error
        return call(input, **options) do |failure|
          raise failure.exception
        end
      end

      s0 = State.call(input, options: options, mapper: self)

      s1 = call!(s0) do |failure|
        return error[failure]
      end

      case s1
      in { value: }
        value
      in { notices: [] }
        raise NotImplementedError, "Notices are not yet supported"
      in { notices: }
        error[Failure.call(failures: notices)]
      end
    end
  end
end
