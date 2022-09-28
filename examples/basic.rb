# frozen_string_literal: true

require "bundler/setup"
Bundler.require
require "remap"

class Hello < Remap::Base
  option :that

  define do
    map :this, to: [:symbol_key, option(:that)]
  end
end

pp Hello.call({ this: "in" }, that: "out")
