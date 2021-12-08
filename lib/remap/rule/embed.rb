# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

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
    #   Person.call({name: "Volvo"}) # => { person: { car: { model: "Volvo" } } }
    class Embed < Unit
      # @return [#call!]
      attribute :mapper, Types::Mapper

      # Evaluates input against mapper and returns the result
      #
      # @param state [State<T>]
      #
      # @return [State<U>]
      def call(state, &error)
        unless error
          raise ArgumentError, "A block is required to evaluate the embed"
        end

        notice = catch :fatal do
          return mapper.call!(state.set(mapper: mapper)) do |failure|
            return error[failure]
          end
        end

        error[state.failure(notice).except(:mapper)]
      end
    end
  end
end
