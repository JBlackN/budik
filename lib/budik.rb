# = budik.rb
# This file contains definitions of the application's command line
# interface.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 19, 2015

require 'colorize'
require 'commander'
require 'date'
require 'fileutils'
require 'json'
require 'net/http'
require 'open3'
require 'r18n-core'
require 'singleton'
require 'socket'
require 'sys/uname'
require 'terminal-table'
require 'uri'
require 'ya2yaml'
require 'yaml'
require 'youtube_addy'
require 'youtube-dl.rb'

require 'budik/command'
require 'budik/config'
require 'budik/devices'
require 'budik/io'
require 'budik/player'
require 'budik/rng'
require 'budik/sources'
require 'budik/storage'
require 'budik/version'

# 'Budik' is an alarm clock that randomly plays an item from your media
# collection (local or YouTube).
module Budik
  # 'Budik' class describes application's command line interface.
  class Budik
    include Commander::Methods

    # Loads strings in language specified in application's options.
    def initialize
      @strings = Config.instance.lang.budik

      @str_config = @strings.commands.config
      @str_run = @strings.commands.run
      @str_sources = @strings.commands.sources
      @str_translate = @strings.commands.translate
    end

    # Describes application's command line interface. Runs the application.
    def run
      program :name, 'Budik'
      program :version, VERSION
      program :description, @strings.description

      commands

      default_command :run

      run!
    end

    private

    # List of commands
    def commands
      command_config(@str_config.options)
      command_run(@str_run.options)
      command_sources(@str_sources.options)
      command_translate
    end

    # Describes and runs command 'config'.
    #
    # - *Args*:
    #   - +str_opts+ -> Command options' strings
    #
    def command_config(str_opts)
      command :config do |c|
        c.syntax = 'budik config [options]'
        c.summary = @str_config.summary
        c.description = @str_config.description
        c.option '-r', '--reset', str_opts.reset
        c.action { |_args, opts| Command.new(:config, opts) }
      end
    end

    # Describes and runs command 'run'.
    #
    # - *Args*:
    #   - +str_opts+ -> Command options' strings
    #
    def command_run(str_opts)
      command :run do |c|
        c.syntax = 'budik run [options]'
        c.summary = @str_run.summary
        c.description = @str_run.description
        command_run_options(c, str_opts)
        c.action { |_args, opts| Command.new(:run, opts) }
      end
    end

    # Describes options for command 'run'.
    #
    # - *Args*:
    #   - +c+ -> Ruby Commander's object
    #   - +str_opts+ -> Command options' strings
    #
    def command_run_options(c, str_opts)
      c.option '-c', '--categories [string]', String, str_opts.categories
      c.option '-d', '--dl-method [string]', String, str_opts.dl_method
      c.option '-n', '--number [integer]', Integer, str_opts.number
      c.option '-p', '--player [string]', String, str_opts.player
      c.option '-r', '--rng [string]', String, str_opts.rng
    end

    # Describes and runs command 'sources'.
    #
    # - *Args*:
    #   - +str_opts+ -> Command options' strings
    #
    def command_sources(str_opts)
      command :sources do |c|
        c.syntax = 'budik sources [options]'
        c.summary = @str_sources.summary
        c.description = @str_sources.description
        c.option '-c', '--categories [string]', String, str_opts.categories
        c.option '-d', '--download', str_opts.download
        c.option '-e', '--edit', str_opts.download
        c.action { |_args, opts| Command.new(:sources, opts) }
      end
    end

    # Describes and runs command 'translate'.
    def command_translate
      command :translate do |c|
        c.syntax = 'budik translate [options]'
        c.summary = @str_translate.summary
        c.description = @str_translate.description
        c.action { |args, _opts| Command.new(:translate, args) }
      end
    end
  end

  Budik.new.run if $PROGRAM_NAME == __FILE__
end
