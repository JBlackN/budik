# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'budik/version'

Gem::Specification.new do |spec|
  spec.name          = "budik"
  spec.version       = Budik::VERSION
  spec.authors       = ["Petr Schmied"]
  spec.email         = ["jblack@paworld.eu"]

  spec.summary       = %q{Alarm clock.}
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "http://jblack.paworld.eu/apps/budik"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "awesome_print"
  spec.add_dependency "commander"
  spec.add_dependency "ya2yaml"
  spec.add_dependency "youtube_addy"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "coveralls"
end