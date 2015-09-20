# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'budik/version'

Gem::Specification.new do |spec|
  spec.name          = 'budik'
  spec.version       = Budik::VERSION
  spec.authors       = ['Petr Schmied']
  spec.email         = ['jblack@paworld.eu']

  spec.summary       = 'Alarm clock.'
  spec.description   = 'Alarm clock that randomly plays a song or'\
    'a video from YouTube or your local collection.'
  spec.homepage      = 'http://jblack.paworld.eu/apps/budik'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    fail 'RubyGems 2.0 or newer is required to protect'\
      'against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize'
  spec.add_dependency 'commander'
  spec.add_dependency 'r18n-core'
  spec.add_dependency 'sys-uname'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'ya2yaml'
  spec.add_dependency 'youtube_addy'
  spec.add_dependency 'youtube-dl.rb'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rdoc'

  spec.post_install_message = 'Please make sure VLC/omxplayer and FFmpeg'\
    "/Libav are installed.\nRun 'budik(.bat) config' to edit app's options"\
    "as needed.\nRun 'budik(.bat) sources -e' to edit your media sources."
end
