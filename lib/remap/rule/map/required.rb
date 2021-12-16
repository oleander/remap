# frozen_string_literal: true

module Remap
  class Rule
    class Map
      using State::Extension

      class Required < Concrete
        attribute :backtrace, Types::Backtrace

        # @see Map#call
        def call(state)
          catch_fatal(state, backtrace) do |s0|
            s2 = path.input.call(s0) do |s1|
              callback(rule.call(s1))
            end

            s3 = s2.then(&path.output)
            s4 = s3.set(path: state.path)

            s4.except(:key)
          end
        end
      end
    end
  end
end
