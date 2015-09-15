module Budik
  # 'Config' class loads and manages app configuration.
  class Config
    include Singleton

    def initialize
      @options = YAML.load_file('./lib/budik/config/options.yml')
      @sources = YAML.load_file(@options['sources']['path'])

      R18n.default_places = './lib/budik/config/lang/'
      R18n.set(@options['lang'])
      @lang = R18n.t
    end

    attr_accessor :lang
    attr_accessor :options
    attr_accessor :sources

    def edit(_opts)
      # TODO
    end

    def reset
      # TODO
    end
  end
end
