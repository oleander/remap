# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Required < Concrete
        attribute :backtrace, Types::Backtrace

        # @see Map#call
        def call(state)
          failure = catch_fatal do |fatal_id|
            s0 = state.set(fatal_id: fatal_id)

            s2 = path.input.call(s0) do |s1|
              s2 = rule.call(s1)
              callback(s2)
            end

            s3 = s2.then(&path.output)
            s4 = s3.set(path: state.path)
            s5 = s4.except(:key)

            return s5.remove_fatal_id
          end

          raise failure.exception(backtrace)
        end
      end
    end
  end
end
