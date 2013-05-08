# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_wamp/version'

Gem::Specification.new do |spec|
  spec.name          = "easy_wamp"
  spec.version       = EasyWamp::VERSION
  spec.authors       = ["Curtis Bissonnette"]
  spec.email         = ["cbissonnette@gmail.com"]
  spec.description   = %q{Provides a simple but full implementation of the wamp websocket protocol}
  spec.summary       = %q{A simple full implementation of the wamp websocket protocol (http://wamp.ws/), with similar syntac as DRB.}
  spec.homepage      = "https://github.com/cjbissonnette/EasyWamp"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  
  spec.add_dependency "websocket-eventmachine-server", "~> 1.0.1"
end
