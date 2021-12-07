# frozen_string_literal: true

module Remap
  module Extensions
    module Object
      refine ::Object do
        # Fallback validation method
        #
        # @yield if block is provided
        #
        # @raise unless block is provided
        def _(&block)
          unless block
            return _ { raise _1 }
          end

          block["Expected a state, got [#{self}] (#{self.class})"]
        end

        # Fallback method used when #get is called on an object that does not respond to #get
        #
        # Block is invoked, if provided
        # Otherwise a symbol is thrown
        #
        # @param path [Array<Key>]
        def get(*path, &block)
          raise PathError, []
        end
        alias_method :fetch, :get
      end
    end
  end
end
