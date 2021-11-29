# frozen_string_literal: true

module Remap
  class Success < Result
    attribute :result, Types::Any

    def inspect
      format("Success<[%<result>s]>", result: JSON.pretty_generate(to_h))
    end

    def to_hash
      { success: result, problems: problems }
    end

    def failure?
      false
    end

    def success?(value = Undefined)
      return true if value.equal?(Undefined)

      result == value
    end

    def fmap(&block)
      new(result: block[result])
    end
  end
end
