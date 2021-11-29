# frozen_string_literal: true

module Remap
  module Operation
    using State::Extension
    include State

    # Public interface for mappers
    #
    # @param input [Any] Data to be mapped
    # @param options [Hash] Mapper arguments
    #
    # @yield [Failure] if mapper fails
    #
    # @return [Success] if mapper succeeds
    def call(input, **options, &error)
      unless block_given?
        return call(input, **options, &:itself)
      end

      state(input, options: options, mapper: self).then do |state|
        call!(state) do |failure|
          return error[failure]
        end.to_result(&error)
      end
    end
  end
end
