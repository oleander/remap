# frozen_string_literal: true

module Remap
  using Extensions::Hash

  class Notice < Dry::Concrete
    attribute? :value, Types::Any
    attribute :reason, String
    attribute :path, Array

    # @return [String]
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
  end
end
