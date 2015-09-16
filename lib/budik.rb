#!/usr/bin/env ruby

# require 'awesome_print'
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

require './lib/budik/command'
require './lib/budik/config'
require './lib/budik/devices'
require './lib/budik/io'
require './lib/budik/player'
require './lib/budik/rng'
require './lib/budik/sources'
require './lib/budik/storage'
require './lib/budik/version'

# 'Budik' is an alarm clock which randomly plays an item from your media
# collection (local or YouTube).
module Budik
  # 'Budik' class is application's main entry point.
  class Budik
    include Commander::Methods

    def initialize
      @strings = Config.instance.lang.budik

      @str_config = @strings.commands.config
      @str_run = @strings.commands.run
      @str_sources = @strings.commands.sources
      @str_translate = @strings.commands.translate
    end

    def run
      program :name, 'Budik'
      program :version, '0.0.1'
      program :description, @strings.description

      commands

      default_command :run

      run!
    end

    private

    def commands
      command_config(@str_config.options)
      command_run(@str_run.options)
      command_sources(@str_sources.options)
      command_translate
    end

    def command_config(str_opts)
      command :config do |c|
        c.syntax = 'budik config [options]'
        c.summary = @str_config.summary
        c.description = @str_config.description
        c.option '-r', '--reset [string]', String, str_opts.reset
        c.action { |_args, opts| Command.new(:config, opts) }
      end
    end

    def command_run(str_opts)
      command :run do |c|
        c.syntax = 'budik run [options]'
        c.summary = @str_run.summary
        c.description = @str_run.description
        command_run_options(c, str_opts)
        c.action { |_args, opts| Command.new(:run, opts) }
      end
    end

    def command_run_options(c, str_opts)
      c.option '-c', '--categories [string]', String, str_opts.categories
      c.option '-d', '--dl-method [string]', String, str_opts.dl_method
      c.option '-n', '--number [integer]', Integer, str_opts.number
      c.option '-p', '--player [string]', String, str_opts.player
      c.option '-r', '--rng [string]', String, str_opts.rng
    end

    def command_sources(str_opts)
      command :sources do |c|
        c.syntax = 'budik sources [options]'
        c.summary = @str_sources.summary
        c.description = @str_sources.description
        c.option '-l', '--list [string]', String, str_opts.list
        c.option '-d', '--download [string]', String, str_opts.download
        c.action { |_args, opts| Command.new(:sources, opts) }
      end
    end

    def command_translate
      command :translate do |c|
        c.syntax = 'budik translate [options]'
        c.summary = @str_translate.summary
        c.description = @str_translate.description
        c.action { |_args, opts| Command.new(:translate, opts) }
      end
    end
  end

  Budik.new.run if $PROGRAM_NAME == __FILE__
end
