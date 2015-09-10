module Budik
  class Options
    include Singleton

    def initialize
      @config = nil
      @options = nil
    end

    attr_reader :config
    attr_reader :options

    def load_config(path, lang)
      if lang
        R18n.default_places = File.dirname(lang)
        R18n.set(File.basename(lang, '.*'))
      else
        R18n.default_places = 'lang/'
        if path
          @config = nil
          R18n.set('en')
          load_options(path)
        else
          @config = YAML.load_file('config/config.yml')
          R18n.set(@config.lang)
          load_options(File.join(@config.options_dir, @config.options))
        end
      end
    end

    def load_options(path)
      @options = YAML.load_file(path)
    end
  end
end
