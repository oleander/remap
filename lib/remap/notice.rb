# frozen_string_literal: true

module Remap
  class Notice < Dry::Interface
    attribute? :value, Types::Any
    attribute :reason, String
    attribute :path, Array

    class Error < Remap::Error
      extend Dry::Initializer

      option :notice, type: Notice
    end

    def inspect
      "#<%s %s>" % [self.class, JSON.pretty_generate(to_hash)]
    end
    alias to_s inspect

    def to_hash
      super.except(:backtrace).reject { |_, value| value.blank? }
    end

    # @return [Error]
    def exception
      Error.new(notice: self)
    end
  end
end
