lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nagios/plugin/version'

Gem::Specification.new do |spec|
  spec.name          = "nagios-plugin"
  spec.version       = Nagios::Plugin::VERSION
  spec.authors       = ["Max Horbul"]
  spec.email         = ["max@gorbul.net"]
  spec.description   = %q{Nagios plugin written in Ruby}
  spec.summary       = %q{This is a base for Nagios plugins in Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
