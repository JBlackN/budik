# = config.rb
# This file contains methods for configuring the application.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 20, 2015

module Budik
  # 'Config' class loads and manages app configuration.
  class Config
    include Singleton

    # Installs the application if not installed.
    # Loads options, sources and language.
    def initialize
      install unless installed?

      @templates_dir = File.dirname(__FILE__) + '/../../config/templates/'
      @options = YAML.load_file(Dir.home + '/.budik/options.yml')
      @sources = YAML.load_file(File.expand_path(@options['sources']['path']))
      @lang = init_lang
    end

    # Sets application's language.
    #
    # - *Returns*:
    #   - R18n::Translation object.
    #
    def init_lang
      R18n.default_places = Dir.home + '/.budik/lang/'
      R18n.set(@options['lang'])
      R18n.t
    end

    # Language strings, options and sources.
    attr_accessor :lang, :options, :sources

    # Opens options file for editing.
    def edit
      options_path = File.expand_path('~/.budik/options.yml')
      open_file(options_path)
    end

    # Installs the application.
    def install
      dir = Dir.home + '/.budik/'
      FileUtils.mkdir_p([dir, dir + 'lang/', dir + 'downloads/'])

      install_options(dir)
      install_sources(dir) unless File.file? dir + sources
      install_lang(dir)
    end

    # Creates options file from template.
    #
    # - *Args*:
    #   - +dir+ -> Directory containing app's configuration (String).
    #
    def install_options(dir)
      options = @templates_dir + 'options/' + platform?.to_s + '.yml'
      FileUtils.cp options, dir + 'options.yml'
    end

    # Creates sources file from template.
    #
    # - *Args*:
    #   - +dir+ -> Directory containing app's configuration (String).
    #
    def install_sources(dir)
      sources = @templates_dir + 'sources/sources.yml'
      FileUtils.cp sources, dir
    end

    # Creates default language file from template.
    #
    # - *Args*:
    #   - +dir+ -> Directory containing app's configuration (String).
    #
    def install_lang(dir)
      lang = @templates_dir + 'lang/en.yml'
      FileUtils.cp lang, dir + 'lang/'
    end

    # Checks if the application is already installed.
    def installed?
      File.file?(Dir.home + '/.budik/options.yml')
    end

    # Opens file in default editor depending on platform.
    #
    # - *Args*:
    #   - +file+ -> File to open (String).
    #
    def open_file(file)
      if @options['os'] == 'windows'
        system('@powershell -Command "' + file + '"')
      else
        editor = ENV['EDITOR'] ? ENV['EDITOR'] : 'vi'
        system(editor + ' "' + file + '"')
      end
    end

    # Returns current platform application's running on.
    #
    # - *Returns*:
    #   - :windows, :linux or :rpi
    #
    def platform?
      os = Sys::Platform.linux? ? :linux : :windows
      rpi?(os) ? :rpi : os
    end

    # Resets app's configuration.
    def reset
      options = @templates_dir + 'options/' + platform?.to_s + '.yml'
      FileUtils.cp(options, Dir.home + '/.budik/options.yml')
    end

    # Checks if application is running on Raspberry Pi.
    #
    # - *Args*:
    #   - +os+ -> Operating system (:windows or :linux)
    # - *Returns*:
    #   - true or false
    #
    def rpi?(os)
      return false unless os == :linux
      cpuinfo = File.read('/proc/cpuinfo')
      hardware = cpuinfo.scan(/[hH]ardware\s*:\s*(\w+)/).first.first
      hardware =~ /BCM270[89]/
    rescue
      false
    end

    # Creates and/or opens language file for translation.
    #
    # - *Args*:
    #   - +lang+ -> Language code (String)
    #
    def translate(lang)
      template = @templates_dir + 'lang/en.yml'
      new_lang = Dir.home + '/.budik/lang/' + lang + '.yml'
      FileUtils.cp template, new_lang
      open_file(new_lang)
    end
  end
end
