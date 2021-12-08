# frozen_string_literal: true

module Remap
  using Extensions::Hash

  class Notice < Dry::Interface
    attribute? :value, Types::Any
    attribute :reason, String
    attribute :path, Array

    class Error < Remap::Error
      extend Dry::Initializer

      param :notice, type: Notice
    end

    def inspect
      "#<%s %s>" % [self.class, to_hash.formatted]
    end
    alias to_s inspect

    # Hash representation of the notice
    #
    # @return [Hash]
    def to_hash
      super.except(:backtrace).compact_blank
    end

    # @return [Error]
    def exception
      Error.new(self)
    end
  end
end
