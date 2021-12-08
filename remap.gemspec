# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "remap"
  spec.version       = "2.1.0"
  spec.authors       = ["Linus Oleander"]
  spec.email         = ["oleander@users.noreply.github.com"]
  spec.homepage      = "https://github.com/oleander/remap"
  spec.license       = "MIT"
  spec.summary       = "An expressive and feature-complete data mapper with intuitive syntax thanks to its DSL"
  spec.description   = <<~DESC
    Re:map; an expressive and feature-complete data mapper with an intuitive syntax designed as a domain-specific language using Ruby 3.0.
    It gives the developer the expressive power of JSONPath, without the hassle of using strings.
    Its compiler is written on top of an immutable, primitive data structure utilizing Rubys
    refinements & pattern matching capabilities – making it blazingly fast
  DESC

  spec.files = Dir["lib/**/*.rb"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "activesupport", "~> 6.1.4.1"
  spec.add_dependency "dry-core", "~> 0.7.1"
  spec.add_dependency "dry-initializer", "~> 3.0.4"
  spec.add_dependency "dry-interface", "~> 1.0.3"
  spec.add_dependency "dry-monads", "~> 1.4.0"
  spec.add_dependency "dry-schema", "~> 1.8.0"
  spec.add_dependency "dry-struct", "~> 1.4.0"
  spec.add_dependency "dry-types", "~> 1.5.1"
  spec.add_dependency "dry-validation", "~> 1.7.0"
  spec.add_dependency "neatjson", "~> 0.9"
  spec.add_dependency "zeitwerk", "~> 2.5.1"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "rubocop", "~> 1.23.0"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rake"

  spec.metadata = { "rubygems_mfa_required" => "true" }
end
