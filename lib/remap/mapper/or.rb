# frozen_string_literal: true

module Remap
  class Mapper
    class Or < Binary
      using State::Extension

      def call!(state, &error)
        unless error
          return call!(state, &exception)
        end

        left.call!(state) do |failure1|
          return right.call!(state) do |failure2|
            return error[failure1.merge(failure2)]
          end
        end
      end
    end
  end
end
