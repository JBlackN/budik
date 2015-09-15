module Budik
  # 'Config' class loads and manages app configuration.
  class Config
    include Singleton

    def initialize
      install unless installed?

      @options = YAML.load_file(Dir.home + '/.budik/options.yml')
      @sources = YAML.load_file(File.expand_path(@options['sources']['path']))
      @lang = init_lang
    end

    def init_lang
      R18n.default_places = Dir.home + '/.budik/lang/'
      R18n.set(@options['lang'])
      R18n.t
    end

    attr_accessor :lang, :options, :sources

    def platform?
      os = Sys::Platform.linux? ? :linux : :windows
      rpi?(os) ? :rpi : os
    end

    def edit(_opts)
      # TODO
    end

    def install
      dir = Dir.home + '/.budik/'
      lang_dir = dir + 'lang/'
      download_dir = dir + 'downloads/'

      options = './config/templates/options/' + platform?.to_s + '.yml'
      sources = './config/templates/sources/sources.yml'
      lang = './config/templates/lang/en.yml'

      FileUtils.mkdir_p([dir, lang_dir, download_dir])
      FileUtils.cp options, dir + 'options.yml'
      FileUtils.cp sources, dir
      FileUtils.cp lang, lang_dir
    end

    def installed?
      File.file?(Dir.home + '/.budik/options.yml')
    end

    def reset
      # TODO
    end

    def rpi?(os)
      return false unless os == :linux
      cpuinfo = File.read('/proc/cpuinfo')
      hardware = cpuinfo.scan(/[hH]ardware\s*:\s*(\w+)/).first.first
      hardware =~ /BCM270[89]/
    rescue
      false
    end
  end
end
