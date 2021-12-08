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

      state = State.call(input, options: options, mapper: self)

      other = call!(state) do |failure|
        return error[failure]
      end

      case other
      in { value:, notices: }
        Success.call(value: value, notices: notices)
      in { notices: [] }
        return error[Failure.call(failures: [other.failure("No data avalible")])]
      in { notices: }
        return error[Failure.call(failures: notices, notices: [])]
      end
    rescue Notice::Error => e
      error[Failure.call(failures: [e.notice])]
    end
  end
end
