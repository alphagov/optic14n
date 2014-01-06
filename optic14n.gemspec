# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'optic14n/version'

Gem::Specification.new do |spec|
  spec.name          = 'optic14n'
  spec.version       = Optic14n::VERSION
  spec.authors       = ['Russell Garner']
  spec.email         = %w(rgarner@zephyros-systems.co.uk)
  spec.description   = %q{Canonicalises URLs.}
  spec.summary       = %q{Specifically, HTTP URLs, for a limited purpose}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'addressable', '~> 2.3'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'gem_publisher', '~> 1.3.0'
end
