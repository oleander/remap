# frozen_string_literal: true

module Remap
  class Static
    class Option < Concrete
      using State::Extension

      attribute :name, Symbol

      # Selects {#value} from {state#params}
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        state.set state.options.fetch(name) {
          return state.problem("Option [#{name}] not found in [#{state.options.inspect}]")
        }
      end
    end
  end
end
