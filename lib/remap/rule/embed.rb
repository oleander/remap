# frozen_string_literal: true

module Remap
  class Rule
    # Embed mappers into each other
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
    class Embed < Unit
      using State::Extension

      attribute :mapper, Types::Mapper

      # Evaluates {input} against {mapper} and returns the result
      #
      # @param state [State<T>]
      #
      # @return [State<U>]
      def call(state)
        mapper.call!(state.set(mapper: mapper)) do |error|
          return state.problem(error)
        end
      end
    end
  end
end
