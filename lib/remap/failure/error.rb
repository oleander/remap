# frozen_string_literal: true

module Remap
  class Failure
    using Extensions::Hash

    class Error < Error
      extend Dry::Initializer

      option :failure, type: Types.Instance(Failure)
      delegate_missing_to :failure

      # @return [String]
      def inspect
        "#<%s %s>" % [self.class, to_hash.formatted]
      end
      alias to_s inspect
    end
  end
end
