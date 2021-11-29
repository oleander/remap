# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development do
  gem "bundler"
  gem "factory_bot", require: false
  gem "guard", require: false
  gem "guard-bundler", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false
  gem "pry", require: true
  gem "reek"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "solargraph", require: false
end

group :test do
  gem "faker"
  gem "rspec"
  gem "simplecov"
  gem "super_diff"
end
