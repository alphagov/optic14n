require "English"
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "optic14n/version"

Gem::Specification.new do |spec|
  spec.name          = "optic14n"
  spec.version       = Optic14n::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]
  spec.description   = "Canonicalises URLs."
  spec.summary       = "Specifically, HTTP URLs, for a limited purpose"
  spec.homepage      = "https://github.com/alphagov/optic14n"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.add_dependency "addressable", "~> 2.7"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop-govuk", "5.1.6"
end
