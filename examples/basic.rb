# frozen_string_literal: true

require "bundler/setup"
Bundler.require
require "remap"

mapper = Remap.define do
  map :e do
    # map :g do

    map :a

    map :b
    # end
  end
end

pp mapper.call({ e: { a: "1", b: "2" } })
