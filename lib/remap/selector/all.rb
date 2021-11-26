# frozen_string_literal: true

module Remap
  class Selector
    class All < Concrete
      using State::Extension

      requirement Types::Enumerable

      def call(state, &block)
        state.bind(quantifier: "*") do |enumerable, inner_state, &error|
          requirement[enumerable] do
            return error["Expected an enumeration"]
          end

          inner_state.map(&block)
        end
      end
    end
  end
end
