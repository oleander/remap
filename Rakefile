# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :yard do
  desc "Verify yard syntax"
  task :verify do
    exec "bundle", "exec", "yardstick", "lib/**/*.rb"
  end

  desc "Verify yard examples"
  task :doctest do
    exec "bundle", "exec", "yard", "doctest"
  end
end

desc "Run all specs"
task :rspec do
  exec "bundle",
       "exec",
       "rspec",
       "--format",
       "RSpec::Github::Formatter",
       "--format",
       "documentation"
end

desc "Run all specs and generate documentation"
task :rubocop do
  exec "bundle", "exec", "rubocop"
end

