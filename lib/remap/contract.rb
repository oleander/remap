module Remap
  class Contract < Dry::Validation::Contract
    def self.call(rules:, options:, contract:, attributes:)
      Class.new(self) do
        rules.each do |rule|
          class_eval(&rule)
        end

        options.each do |option|
          class_eval(&option)
        end

        schema(contract)
      end.new(**attributes)
    end
  end
end
