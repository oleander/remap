# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "guard", require: false
  gem "guard-bundler", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false

  gem "reek", require: false
  gem "yard", require: false
  gem "yard-coderay", require: false
  gem "yard-doctest", require: false
  gem "yard-rspec", require: false
  gem "yard-spellcheck", require: false
end

group :test, :development do
  gem "bundler", "~> 2"
  gem "pry"
end

group :test do
  gem "factory_bot"
  gem "faker"
  gem "rspec"
  gem "rspec-github"
  gem "simplecov"
end
