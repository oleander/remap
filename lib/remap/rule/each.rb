# frozen_string_literal: true

module Remap
  class Rule
    class Each < Value
      using State::Extension

      attribute :rule, Types.Interface(:call)

      # Iterates over {state} and passes each value to {rule}
      # Restores {path} before returning state
      #
      #
      # # @example
      #   class Mapper < Remap::Base
      #     define do
      #       map :people, to: :names do
      #         each do
      #           map(:name)
      #         end
      #       end
      #     end
      #   end
      #
      #   Mapper.call(people: [{ name: "John" }, { name: "Jane" }]) # => { names: ["John", "Jane"] }
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state.map do |inner_state|
          rule.call(inner_state)
        end
      end
    end
  end
end
