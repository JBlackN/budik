#!/usr/bin/env ruby

#require 'awesome_print'
require 'commander/import'
#require 'fileutils'
#require 'json'
#require 'net/http'
#require 'open3'
require 'r18n-core'
require 'singleton'
#require 'socket'
#require 'uri'
require 'ya2yaml'
require 'yaml'
#require 'youtube_addy'

require './lib/budik/command'
require './lib/budik/config'
#require './budik/devices.rb'
#require './budik/player.rb'
#require './budik/rng.rb'
#require './budik/sources.rb'
require './lib/budik/version'

module Budik
  program :name, 'Budík'
  program :version, '0.0.1'
  program :description, 'Alarm clock which randomly plays a song or a video from YouTube or your local collection.'

  global_option('-L', '--language [string]', 'Specify custom path to your language file (default: "./config/lang.yml").') {}
  global_option('-O', '--options [string]', 'Specify custom path to your options file (default: "./config/options.yml").') {}
  global_option('-S', '--sources [string]', 'Specify custom path to your media sources file (default: "./config/sources.yml").') {}

  default_command :run

  command :config do |c|
    c.syntax = 'Budík.rb config [options]'
    c.summary = 'Edit program configuration.'
    c.description = 'Open options file in your default editor.'
    c.option '-r', '--reset [string]', String, 'Resets configuration file to default values.'
    c.action do |_args, opts|
      command_config(_args, opts)
    end
  end

  command :run do |c|
    c.syntax = 'Budík.rb run [options]'
    c.summary = 'DEFAULT: Runs alarm.'
    c.description = 'Runs alarm with specified options. CLI options > options.yml.'
    c.option '-c', '--categories [array]', Array, 'Limit selection by categories. Example usage: "cat1.subcat1 cat2.subcat1.subsubcat1 .excludethis.subcat etc."'
    c.option '-d', '--download-method [string]', String, 'Override download method set in your active options.'
    c.option '-n', '--number [integer]', Integer, 'Override selection using random number generator by specifying fixed number.'
    c.option '-p', '--player [string]', String, 'Override which player to use.'
    c.option '-r', '--rng [string]', String, 'Override random number generation method specified in your options.yml file. Possible values: "hwrng", "random.org", "rand-hwrng-seed", "rand". Default value: "hwrng".'
    c.action do |_args, opts|
      command_run(_args, opts)
    end
  end

  command :set do |c|
    c.syntax = 'Budík.rb set [options]'
    c.summary = 'Set alarm.'
    c.description = 'Set alarm using systemd timers, cron or schtasks.'
    c.action do |_args, opts|
      command_set(_args, opts)
    end
  end

  command :sources do |c|
    c.syntax = 'Budík.rb sources [options]'
    c.summary = 'Manage source(s).'
    c.description = 'List or download source(s) or edit your sources file in your default editor (default: edit).'
    c.option '-l', '--list [string]', String, 'List sources. Can be restricted by categories. DEFAULT option. Usage: list "all|category.subcategory .exclude.this". Default: list "all"'
    c.option '-d', '--download [string]', String, 'Downloads source(s). Usage: download "all|number|{category: category, number: number}|path|name". Default: download "all".'
    c.action do |_args, opts|
      command_sources(_args, opts)
    end
  end

  alias_command :test, :'run', '--trace'

  command :translate do |c|
    c.syntax = 'Budík.rb translate [options]'
    c.summary = 'Translate app.'
    c.description = 'Opens your language file in your default editor.'
    c.action do |_args, opts|
      command_translate(_args, opts)
    end
  end

  command :unset do |c|
    c.syntax = 'Budík.rb unset [options]'
    c.summary = 'Unset alarm.'
    c.description = 'Unset alarm.'
    c.action do |_args, opts|
      command_unset(_args, opts)
    end
  end
end
