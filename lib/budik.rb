#!/usr/bin/env ruby

#require 'awesome_print'
require 'commander'
require 'date'
require 'fileutils'
require 'json'
require 'net/http'
require 'open3'
require 'r18n-core'
require 'singleton'
require 'socket'
require 'terminal-table'
require 'uri'
require 'ya2yaml'
require 'yaml'
require 'youtube_addy'
require 'youtube-dl.rb'

require './lib/budik/command'
require './lib/budik/config'
require './lib/budik/devices'
require './lib/budik/output'
require './lib/budik/player'
require './lib/budik/rng'
require './lib/budik/sources'
require './lib/budik/version'

module Budik
  class Budik
    include Commander::Methods

    def initialize
      @strings = Config.instance.lang.budik
    end

    def run
      program :name, 'Budik'
      program :version, '0.0.1'
      program :description, @strings.description

      default_command :run

      command :config do |c|
        str_config = @strings.commands.config
        str_opts = @strings.commands.config.options

        c.syntax = 'budik config [options]'
        c.summary = str_config.summary
        c.description = str_config.description
        c.option '-r', '--reset [string]', String, str_opts.reset

        c.action do |_args, opts|
          Command.instance.config(_args, opts)
        end
      end

      command :run do |c|
        str_run = @strings.commands.run
        str_opts = @strings.commands.run.options

        c.syntax = 'budik run [options]'
        c.summary = str_run.summary
        c.description = str_run.description
        c.option '-c', '--categories [string]', String, str_opts.categories
        c.option '-d', '--dl-keep [string]', String, str_opts.dl_keep
        c.option '-n', '--number [integer]', Integer, str_opts.number
        c.option '-p', '--player [string]', String, str_opts.player
        c.option '-r', '--rng [string]', String, str_opts.rng

        c.action do |_args, opts|
          Command.instance.run(_args, opts)
        end
      end

      command :sources do |c|
        str_sources = @strings.commands.sources
        str_opts = @strings.commands.sources.options

        c.syntax = 'budik sources [options]'
        c.summary = str_sources.summary
        c.description = str_sources.description
        c.option '-l', '--list [string]', String, str_opts.list
        c.option '-d', '--download [string]', String, str_opts.download

        c.action do |_args, opts|
          Command.instance.sources(_args, opts)
        end
      end

      alias_command :test, :'run', '--trace'

      command :translate do |c|
        str_translate = @strings.commands.translate

        c.syntax = 'budik translate [options]'
        c.summary = str_translate.summary
        c.description = str_translate.description

        c.action do |_args, opts|
          Command.instance.translate(_args, opts)
        end
      end

      run!
    end
  end

  Budik.new.run if $0 == __FILE__
end
