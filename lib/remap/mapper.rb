# frozen_string_literal: true

module Remap
  # @abstract
  class Mapper < Struct
    # Tries {self} and {other} and returns the first successful result
    #
    # @param other [Mapper]
    #
    # @return [Mapper::Or]
    module Operations
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

    include Operations
    extend Operations

    # Creates a new mapper using {state}
    #
    # @param state [State]
    #
    # @yield [State]
    #   If the call fails, the block is invoked with the state
    # @yieldreturn [State]
    #
    # @return [State]
    #
    # @private
  end
end
