# frozen_string_literal: true

module Remap
  class Rule
    using State::Extension

    # Set path to a static value
    #
    # @example Given an option
    #   class Mapper < Remap::Base
    #     option :name
    #
    #     define do
    #       set [:person, :name], to: option(:name)
    #     end
    #   end
    #
    #   Mapper.call({}, name: "John") # => { person: { name: "John" } }
    #
    # @example Given a value
    #   class Mapper < Remap::Base
    #     define do
    #       set [:api_key], to: value("ABC-123")
    #     end
    #   end
    #
    #   Mapper.call({}) # => { api_key: "ABC-123" }
    class Set < Concrete
      # @return [Static]
      attribute :value, Static, alias: :rule

      # @return [Path::Output]
      attribute :path, Path::Output

      # Returns value mapped to path regardless of input
      #
      # @param state [State<T>]
      #
      # @return [State<U>]
      def call(state)
        rule.call(state).then(&path)
      end
    end
  end
end
