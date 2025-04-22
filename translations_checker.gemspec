
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

  # Rails 8 requires >= 3.2
  spec.required_ruby_version = ENV["CI_RUBY_VERSION"] || "~> 3.1"

  spec.add_runtime_dependency "activesupport", ENV["CI_RAILS_VERSION"] || "~> 7"
  spec.add_runtime_dependency "naught", "~> 1.1.0"
  spec.add_runtime_dependency 'concurrent-ruby', '1.3.4'

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "pry", "~> 0.15.2"
  spec.add_development_dependency "rake", ">= 12.3"
  spec.add_development_dependency "reek", "~> 4.7.3"
  spec.add_development_dependency "rspec", ">= 3.13.0"
  spec.add_development_dependency "rubocop", "~> 0.51.0"
end
