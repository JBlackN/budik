module Budik
  # 'Config' class loads and manages app configuration.
  class Config
    include Singleton

    def initialize
      install(Dir.home + '/.budik/') unless installed?

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

    def edit
      options_path = File.expand_path('~/.budik/options.yml')
      open_file(options_path)
    end

    def install(dir)
      options = './config/templates/options/' + platform?.to_s + '.yml'
      sources = './config/templates/sources/sources.yml'
      lang = './config/templates/lang/en.yml'

      FileUtils.mkdir_p([dir, dir + 'lang/', dir + 'downloads/'])
      FileUtils.cp options, dir + 'options.yml'
      FileUtils.cp sources, dir unless File.file? dir + sources
      FileUtils.cp lang, dir + 'lang/'
    end

    def installed?
      File.file?(Dir.home + '/.budik/options.yml')
    end

    def open_file(file)
      if @options['os'] == 'windows'
        system('@powershell -Command "' + file + '"')
      else
        editor = ENV['EDITOR'] ? ENV['EDITOR'] : 'vi'
        system(editor + ' "' + file + '"')
      end
    end

    def platform?
      os = Sys::Platform.linux? ? :linux : :windows
      rpi?(os) ? :rpi : os
    end

    def reset
      options = './config/templates/options/' + platform?.to_s + '.yml'
      FileUtils.cp(options, Dir.home + '/.budik/options.yml')
    end

    def rpi?(os)
      return false unless os == :linux
      cpuinfo = File.read('/proc/cpuinfo')
      hardware = cpuinfo.scan(/[hH]ardware\s*:\s*(\w+)/).first.first
      hardware =~ /BCM270[89]/
    rescue
      false
    end

    def translate(lang)
      template = './config/templates/lang/en.yml'
      new_lang = Dir.home + '/.budik/lang/' + lang + '.yml'
      FileUtils.cp template, new_lang
      open_file(new_lang)
    end
  end
end
