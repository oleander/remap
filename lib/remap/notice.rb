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

    # Used by State to skip mapping rules
    #
    # @raise [Notice::Ignore]
    def ignore!
      raise Ignore.new(notice: self)
    end

    # Used by the state to halt mappers
    #
    # @raise [Notice::Fatal]
    def fatal!
      raise Fatal.new(notice: self)
    end
  end
end
