
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "translations_checker/version"

Gem::Specification.new do |spec|
  spec.name          = "translations_checker"
  spec.version       = TranslationsChecker::VERSION
  spec.authors       = ["John Carney"]
  spec.email         = ["jcarney@locomote.com"]

  spec.summary       = "Checks translation placeholders"
  spec.description   = "Checks your locale files to ensure that translations placeholder are available."
  spec.homepage      = "https://github.com/locomote/translations_checker"
  spec.license       = "MIT"

  spec.files         = Dir["{lib,bin}/**/*"] + %w(README.md)
  spec.bindir        = "bin"
  spec.executables   = %w(translations_checker)
  spec.require_paths = %w(lib)

  spec.required_ruby_version = ">= 2.6.7"

  spec.add_runtime_dependency "activesupport", "< 7.1"
  spec.add_runtime_dependency "naught", "~> 1.1.0"

  spec.add_development_dependency "bundler", "~> 2.2.17"
  spec.add_development_dependency "pry", "~> 0.11.3"
  spec.add_development_dependency "rake", ">= 12.3"
  spec.add_development_dependency "reek", "~> 4.7.3"
  spec.add_development_dependency "rspec", ">= 3.7.0"
  spec.add_development_dependency "rubocop", "~> 0.51.0"
end
