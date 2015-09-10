module Budik
  class Config
    include Singleton

    def initialize
      R18n.default_places = './lib/budik/config/lang/'

      @lang = nil
      @options = nil
      @sources = nil
    end

    attr_accessor :lang
    attr_accessor :options
    attr_accessor :sources

    def edit(opts)
      # TODO
    end

    def load(opts)
      locale = opts.has_key?(:language) ? opts[:language] : 'en'
      options_path = opts.has_key?(:options) ? opts[:options] : './lib/budik/config/options.yml'
      sources_path = opts.has_key?(:sources) ? opts[:sources] : './lib/budik/config/sources.yml'

      R18n.set(locale)
      @lang = R18n.t
      @options = YAML.load_file(options_path)
      @sources = YAML.load_file(sources_path)

    end

    def reset
      # TODO
    end
  end
end
