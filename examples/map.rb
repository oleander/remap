# frozen_string_literal: true

require "bundler/setup"

Bundler.require

require "remap"

class Mapper < Remap::Base
  define do
    map :a, :b
  end
end

pp Mapper.call({ a: { c: "ok" } })
