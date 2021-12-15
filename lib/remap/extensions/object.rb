# frozen_string_literal: true

module Remap
  module Extensions
    module Object
      refine ::Object do
        # @return [Any]
        def to_hash
          self
        end

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

        # @return [Array]
        #
        # @see Extension::Paths::Hash
        def paths
          []
        end

        # Fallback method used when #get is called on an object that does not respond to #get
        #
        # Block is invoked, if provided
        # Otherwise a symbol is thrown
        #
        # @param path [Array<Key>]
        def get(*path, trace: [], &fallback)
          return self if path.empty?

          unless block_given?
            return get(*path, trace: trace) do
              raise PathError, trace
            end
          end

          yield
        end
        alias_method :fetch, :get

        # return [Any]
        def formatted
          self
        end
      end
    end
  end
end
