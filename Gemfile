# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec


group :development do
  gem "pry", require: true
  gem "factory_bot", require: false
  gem "guard", require: false
  gem "guard-bundler", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false
  gem "solargraph", require: false
  gem "reek"
  gem "rubocop"
  gem "bundler"
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end

group :test do
  gem "super_diff"
  gem "faker"
  gem "rspec"
  gem "simplecov"
end

