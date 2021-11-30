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
    def call(input, **options)
      state = State.call(input, options: options, mapper: self)
      other = call!(state, &:itself)

      case other
      in { failures: [], value:, notices: }
        Success.call(value: value, notices: notices)
      in { failures: [], notices: [] }
        Failure.call(failures: [other.failure("No data avalible")])
      in { failures: [], notices: }
        Failure.call(failures: notices, notices: [])
      in { failures: , notices: }
        Failure.call(failures: failures, notices: notices)
      end
    rescue Notice::Error => e
      Result.call(failures: [e.notice])
    end
  end
end
