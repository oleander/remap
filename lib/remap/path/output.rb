module Remap
  class Path
    class Output < Unit
      attribute :segments, Types.Array(Types::Key)

      using State::Extensions::Enumerable
      using State::Extension

      # @return [State]
      def call(state)
        state.fmap do |value|
          segments.hide(value)
        end
      end
    end
  end
end
