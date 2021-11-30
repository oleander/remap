# frozen_string_literal: true

module Remap
  class Rule
    # Represents a block defined by a rule
    class Collection < Dry::Interface
      attribute :rules, Array

      # @param state [State]
      #
      # @return [State]
      #
      # @abstract
      def call(_state)
        raise NotImplementedError, "#{self.class}#call not implemented"
      end

      # @return [Proc]
      def to_proc
        method(:call).to_proc
      end
    end
  end
end
