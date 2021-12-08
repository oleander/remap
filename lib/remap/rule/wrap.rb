# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Wraps rule in a type
    #
    # @example Maps { name: "Ford" } to { cars: ["Ford"] }
    #   class Mapper < Remap::Base
    #     define do
    #       to :cars do
    #         wrap(:array) do
    #           map :name
    #         end
    #       end
    #     end
    #   end
    #
    #   Mapper.call({ name: "Ford" }) # => { cars: ["Ford"] }
    class Wrap < Concrete
      # @return [:array]
      attribute :type, Value(:array)

      # @return [Rule]
      attribute :rule, Rule

      # Wraps the output from {#rule} in a {#type}
      #
      # @see Rule#call
      def call(...)
        rule.call(...).fmap { Array.wrap(_1) }
      end
    end
  end
end
