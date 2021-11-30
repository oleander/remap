# frozen_string_literal: true

require "bundler/setup"

Bundler.require

require "remap"

class Mapper < Remap::Base
  define do
    set :key, to: option(:id)
  end
end

result = Mapper.call({}).result
pp result # => { key: 'ABC-123', nickname: 'John', car: 'VOLVO' }
