# frozen_string_literal: true

module Remap
  class PathError < Error
    # @return [Array<Key>]
    attr_reader :path

    def initialize(path)
      super(path.join("."))
      @path = path
    end
  end
end
