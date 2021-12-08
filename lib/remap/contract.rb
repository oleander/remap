# frozen_string_literal: true

module Remap
  class Contract < Dry::Validation::Contract
    # Constructs a contract used to validate mapper input
    #
    # @param rules [Array<Proc>]
    # @param options [Hash]
    # @param contract [Proc]
    # @param attributes [Hash]
    #
    # @return [Contract]
    def self.call(rules:, options:, contract:, attributes:)
      Class.new(self) do
        rules.each do |rule|
          instance_exec(&rule)
        end

        options.each do |option|
          instance_exec(&option)
        end

        schema(contract)
      end.new(**attributes)
    end
  end
end
