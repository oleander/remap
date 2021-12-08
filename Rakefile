# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "json"
require "bump"

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

  desc "Generate yard docs"
  task :docs do
    exec "bundle", "exec", "yard", "doc", "-o", "docs/"
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

desc "Generate coverage report used by the CI"
task :coverage do
  coverage_path = Pathname(__dir__).join("coverage/coverage.json")
  coverage_data = coverage_path.read
  coverage_report = JSON.parse(coverage_data, symbolize_names: true)
  puts coverage_report.dig(:metrics, :covered_percent).round(2)
end

desc "Run all specs and generate documentation"
task :rubocop do
  exec "bundle", "exec", "rubocop"
end

namespace :gem do
  desc "Build and release gem"
  task :release do
    Bump::Bump.run("patch", commit: true, bundle: true, tag: true)
    exec "bundle", "exec", "rake", "release"
  end
end
