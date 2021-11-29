# frozen_string_literal: true

module Remap
  class Rule
    class Collection < Dry::Interface
      attribute :rules, Array

      # @abstract
      #
      # @param state [State]
      #
      # @return [State]
      def call(state)
        raise NotImplementedError, "#{self.class}#call not implemented"
      end

      # @return [Proc]
      def to_proc
        method(:call).to_proc
      end
    end
  end
end
