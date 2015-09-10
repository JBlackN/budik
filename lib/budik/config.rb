module Budik
  class Config
    include Singleton

    def initialize
      @lang = nil
      @options = nil
      @sources = nil
    end

    attr_accessor :lang
    attr_accessor :options
    attr_accessor :sources

    def edit(opts)
    end

    def load(opts)
      #@lang = opts.language ? opts.language : './config/lang.yml'
      #@lang = YAML.load_file(@lang)
    end

    def reset
    end
  end
end
