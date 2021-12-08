# frozen_string_literal: true

module Remap
  class Rule
    class Collection
      using State::Extension

      # Represents a non-empty rule block
      #
      # @example A collection containing a single rule
      #   state = Remap::State.call("A")
      #   void = Remap::Rule::Void.call({})
      #   rule = Remap::Rule::Collection.call([void])
      #   error = -> failure { raise failure.exception }
      #   rule.call(state, &error).fetch(:value) # => "A"
      class Filled < Unit
        # @return [Array<Rule>]
        attribute :rules, [Types.Interface(:call)], min_size: 1

        # Represents a non-empty define block with one or more rules
        # Calls every {#rules} with state and merges the output
        #
        # @param state [State]
        #
        # @return [State]
        def call(state, &error)
          unless error
            raise ArgumentError, "Collection::Filled#call(state, &error) requires a block"
          end

          rules.map do |rule|
            rule.call(state) do |failure|
              return error[failure]
            end
          end.reduce(&:combine)
        end
      end
    end
  end
end
