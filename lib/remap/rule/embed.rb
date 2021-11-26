# frozen_string_literal: true

module Remap
  class Rule
    class Embed < Value
      using State::Extension

      attribute :mapper, Types::Mapper

      # Evaluates {input} against {mapper} and returns the result
      #
      # @param state [State]
      #
      # @example Embed Mapper A into B
      #   class Car < Remap::Base
      #     define do
      #       map :name, to: :model
      #     end
      #   end
      #
      #   class Person < Remap::Base
      #     define do
      #       to :person do
      #         to :car do
      #           embed Car
      #         end
      #       end
      #     end
      #   end
      #
      #   Person.call(name: "Volvo") # => { person: { car: { name: "Volvo" } } }
      #
      #
      # @return [State]
      def call(state)
        mapper.call!(state.set(mapper: mapper)) do |error|
          return state.problem(error)
        end
      end
    end
  end
end
