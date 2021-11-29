# frozen_string_literal: true

module Remap
  class Mapper
    module Operations
      # Tries {self} and {other} and returns the first successful result
      #
      # @param other [Mapper]
      #
      # @return [Mapper::Or]
      def |(other)
        Or.new(left: self, right: other)
      rescue Dry::Struct::Error => e
        raise ArgumentError, e.message
      end

      # Returns a successful result when {self} & {other} are successful
      #
      # @param other [Mapper]
      #
      # @return [Mapper::And]
      def &(other)
        And.new(left: self, right: other)
      rescue Dry::Struct::Error => e
        raise ArgumentError, e.message
      end

      # Returns a successful result when only one of {self} & {other} are successful
      #
      # @param other [Mapper]
      #
      # @return [Mapper:Xor]
      def ^(other)
        Xor.new(left: self, right: other)
      rescue Dry::Struct::Error => e
        raise ArgumentError, e.message
      end
    end
  end
end
