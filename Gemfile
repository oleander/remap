# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "debug"
gem "pry"

gem "benchmark-ips", require: false
gem "bump", require: false
gem "reek", require: false
gem "rubocop", "~> 1", require: false
gem "rubocop-md", require: false
gem "rubocop-performance", require: false
gem "rubocop-rake", require: false
gem "rubocop-rspec", require: false
gem "yard", require: false
gem "yard-coderay", require: false
gem "yard-doctest", require: false
gem "yard-rspec", require: false
gem "yard-spellcheck", require: false
gem "yardstick", require: false

group :test do
  gem "factory_bot"
  gem "faker"
  gem "rspec"
  gem "rspec-benchmark"
  gem "rspec-collection"
  gem "rspec-collection_matchers"
  gem "rspec-github"
  gem "rspec-its"
  gem "simplecov"
  gem "simplecov-cobertura"
end

group :development, :test do
  gem "ruby-debug-ide"

  platform :jruby do
    gem "ruby-debug-base"
  end

  platform :ruby do
    gem "debase", "~> 0.2.5.beta2"
  end

  gem "bundler"
  gem "panolint"
  gem "rake"
  gem "solargraph"
end
