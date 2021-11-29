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
      new_state = state(input, options: options, mapper: self)

      new_state = call!(new_state) do |failure|
        return Failure.new(reasons: failure, problems: new_state.problems)
      end

      if error
        return error[new_state]
      end

      value = new_state.fetch(:value) do
        return Failure.new(reasons: new_state.failure("No mapped data"), problems: new_state.problems)
      end

      Success.new(problems: new_state.problems, result: value)
    end
  end
end
