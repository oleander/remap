# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "remap"
  spec.version       = "2.0.3"
  spec.authors       = ["Linus Oleander"]
  spec.email         = ["oleander@users.noreply.github.com"]
  spec.homepage      = "https://github.com/oleander/remap"
  spec.summary       = "Re::map"
  spec.license       = "MIT"
  spec.summary       = "Makes mapping easy"

  spec.files         = Dir["lib/**/*.rb"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "activesupport"
  spec.add_dependency "dry-configurable"
  spec.add_dependency "dry-core"
  spec.add_dependency "dry-initializer"
  spec.add_dependency "dry-interface"
  spec.add_dependency "dry-logic"
  spec.add_dependency "dry-monads"
  spec.add_dependency "dry-schema"
  spec.add_dependency "dry-validation"
  spec.add_dependency "dry-struct"
  spec.add_dependency "zeitwerk"
  spec.add_dependency "dry-types"
  spec.add_dependency "rake"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-github"
end
