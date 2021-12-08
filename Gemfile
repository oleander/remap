# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "guard", require: false
  gem "guard-bundler", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false

  gem "rubocop-md", require: false
  gem "rubocop-rspec", require: false

  gem "bump"
  gem "reek", require: false
  gem "yard"
  gem "yard-coderay"
  gem "yard-doctest"
  gem "yard-rspec"
  gem "yard-spellcheck"
  gem "yardstick", require: false
end

group :test, :development do
  gem "bundler", "~> 2"
  gem "pry"
end

group :test do
  gem "factory_bot"
  gem "faker"
  gem "rspec"
  gem "rspec-collection"
  gem "rspec-github"
  gem "rspec-its"
  gem "simplecov"
  gem "simplecov-cobertura"
end

gem "benchmark-ips"
