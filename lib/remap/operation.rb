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

      other = State.call(input, options: options, mapper: self).then do |state|
        call!(state) do |failure|
          return error[failure]
        end
      end

      case other
      in { value: }
        value
      in { notices: [] }
        error[other.failure("No return value")]
      in { notices: }
        error[Failure.call(failures: notices)]
      end
    end
  end
end
