# frozen_string_literal: true

module Remap
  class Failure < Result
    attribute :reasons, Types::Hash

    def inspect
      format("Failure<[%<result>s]>", result: JSON.pretty_generate(to_h))
    end

    def to_hash
      { failure: reasons, problems: problems }
    end

    def failure?(*)
      true
    end

    def success?(*)
      false
    end

    def fmap
      self
    end
  end
end
