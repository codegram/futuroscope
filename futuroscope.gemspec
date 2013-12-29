# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'futuroscope/version'

Gem::Specification.new do |spec|
  spec.name          = "futuroscope"
  spec.version       = Futuroscope::VERSION
  spec.authors       = ["Josep Jaume Rey Peroy"]
  spec.email         = ["josepjaume@gmail.com"]
  spec.description   = %q{Futuroscope is yet another simple gem that implements the Futures concurrency pattern.}
  spec.summary = %q{Futuroscope is yet another simple gem that implements the Futures concurrency pattern.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-mocks"
  spec.add_runtime_dependency 'rubysl' if RUBY_ENGINE == 'rbx'
end
