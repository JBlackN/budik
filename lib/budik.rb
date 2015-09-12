#!/usr/bin/env ruby

#require 'awesome_print'
require 'commander'
require 'fileutils'
require 'json'
require 'net/http'
require 'open3'
require 'r18n-core'
require 'singleton'
require 'socket'
require 'uri'
require 'ya2yaml'
require 'yaml'
require 'youtube_addy'
require 'youtube-dl.rb'

require './lib/budik/command'
require './lib/budik/config'
require './lib/budik/devices'
require './lib/budik/player'
require './lib/budik/rng'
require './lib/budik/sources'
require './lib/budik/version'

module Budik
  class Budik
    include Commander::Methods

    def run
      program :name, 'Budík'
      program :version, '0.0.1'
      program :description, 'Alarm clock which randomly plays a song or a video from YouTube or your local collection.'

      default_command :run

      command :config do |c|
        c.syntax = 'Budík.rb config [options]'
        c.summary = 'Edit program configuration.'
        c.description = 'Open options file in your default editor.'
        c.option '-r', '--reset [string]', String, 'Resets configuration file to default values.'
        c.action do |_args, opts|
          Command.instance.config(_args, opts)
        end
      end

      command :run do |c|
        c.syntax = 'Budík.rb run [options]'
        c.summary = 'DEFAULT: Runs alarm.'
        c.description = 'Runs alarm with specified options. CLI options > options.yml.'
        c.option '-c', '--categories [string]', String, 'Limit selection by categories. Example usage: "cat1.subcat1 cat2.subcat1.subsubcat1 .excludethis.subcat etc."'
        c.option '-d', '--download-keep [string]', String, 'Override download method set in your active options.'
        c.option '-n', '--number [integer]', Integer, 'Override selection using random number generator by specifying fixed number.'
        c.option '-p', '--player [string]', String, 'Override which player to use.'
        c.option '-r', '--rng [string]', String, 'Override random number generation method specified in your options.yml file. Possible values: "hwrng", "random.org", "rand-hwrng-seed", "rand". Default value: "hwrng".'
        c.action do |_args, opts|
          Command.instance.run(_args, opts)
        end
      end

      command :set do |c|
        c.syntax = 'Budík.rb set [options]'
        c.summary = 'Set alarm.'
        c.description = 'Set alarm using systemd timers, cron or schtasks.'
        c.action do |_args, opts|
          Command.instance.set(_args, opts)
        end
      end

      command :sources do |c|
        c.syntax = 'Budík.rb sources [options]'
        c.summary = 'Manage source(s).'
        c.description = 'List or download source(s) or edit your sources file in your default editor (default: edit).'
        c.option '-l', '--list [string]', String, 'List sources. Can be restricted by categories. DEFAULT option. Usage: list "all|category.subcategory .exclude.this". Default: list "all"'
        c.option '-d', '--download [string]', String, 'Downloads source(s). Usage: download "all|number|{category: category, number: number}|path|name". Default: download "all".'
        c.action do |_args, opts|
          Command.instance.sources(_args, opts)
        end
      end

      alias_command :test, :'run', '--trace'

      command :translate do |c|
        c.syntax = 'Budík.rb translate [options]'
        c.summary = 'Translate app.'
        c.description = 'Opens your language file in your default editor.'
        c.action do |_args, opts|
          Command.instance.translate(_args, opts)
        end
      end

      command :unset do |c|
        c.syntax = 'Budík.rb unset [options]'
        c.summary = 'Unset alarm.'
        c.description = 'Unset alarm.'
        c.action do |_args, opts|
          Command.instance.unset(_args, opts)
        end
      end

      run!
    end
  end

  Budik.new.run if $0 == __FILE__
end
