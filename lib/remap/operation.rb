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

      init_state = state(input, options: options, mapper: self)

      new_state = call!(init_state) do |failure|
        return error[Failure.call(reasons: failure)]
      end

      value = new_state.fetch(:value) do
        return error[Failure.new(
          reasons: new_state.failure("No mapped data"),
          problems: new_state.problems
        )]
      end

      Success.new(problems: new_state.problems, result: value)
    end
  end
end
