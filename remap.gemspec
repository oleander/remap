# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "remap"
  spec.version       = "2.0.3"
  spec.authors       = ["Linus Oleander"]
  spec.email         = ["oleander@users.noreply.github.com"]
  spec.homepage      = "https://github.com/oleander/remap"
  spec.license       = "MIT"
  spec.summary       = "Makes mapping easy"

  spec.files         = Dir["lib/**/*.rb"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "activesupport", "~> 6.1.4.1"
  spec.add_dependency "dry-configurable", "~> 0.13.0"
  spec.add_dependency "dry-core", "~> 0.7.1"
  spec.add_dependency "dry-initializer", "~> 3.0.4"
  spec.add_dependency "dry-interface", "~> 1.0.3"
  spec.add_dependency "dry-monads", "~> 1.4.0"
  spec.add_dependency "dry-schema", "~> 1.8.0"
  spec.add_dependency "dry-struct", "~> 1.4.0"
  spec.add_dependency "dry-types", "~> 1.5.1"
  spec.add_dependency "dry-validation", "~> 1.7.0"
  spec.add_dependency "zeitwerk", "~> 2.5.1"

  spec.metadata = {
    "rubygems_mfa_required" => "true"
  }
end
