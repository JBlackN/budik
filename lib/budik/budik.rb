#!/usr/bin/env ruby

require 'awesome_print'
require 'commander/import'
require 'fileutils'
require 'json'
require 'net/http'
require 'open3'
require 'socket'
require 'uri'
require 'ya2yaml'
require 'yaml'
require 'youtube_addy'

require './config.rb'
require './devices.rb'
require './options.rb'
require './player.rb'
require './rng.rb'
require './sources.rb'

program :name, 'Budík.rb'
program :version, '0.0.1'
program :description, 'Alarm clock which randomly plays a song or a video from YouTube or your local collection.'

global_option('-O', '--options [string]', 'Specify custom path to your options file (default: active options set in "options.yml").') {}
global_option('-S', '--sources [string]', 'Specify custom path to your media sources file (default: "sources.yml").') {}

default_command :run

command :config do |c|
  c.syntax = 'Budík.rb config [options]'
  c.summary = 'Edit program configuration.'
  c.description = 'Interactive way to edit your config.yml file.'
  c.option '-n', '--new [string]', String, 'Create new configuration file with specified name (name => options-name.yml). Default: reset options.yml.'
  c.option '-e', '--edit [string]', String, 'Edit configuration file with specified name (name => options-name.yml). Default: edit options.yml.'
  c.option '-s', '--set [string]', String, 'Set configuration file with specified name (name => options-name.yml) as default. Default: set options.yml as default.'
  c.option '-d', '--delete [string]', String, 'Delete configuration file with specified name (name => options-name.yml). Default: does nothing.'
  c.option '-a', '--app', 'Edit application\'s main configuration file.'
  c.action do |args, opts|
    command_config(args, opts)
  end
end

command :run do |c|
  c.syntax = 'Budík.rb run [options]'
  c.summary = 'DEFAULT: Runs alarm.'
  c.description = 'Runs alarm with specified options. CLI options > options.yml.'
  c.option '-c', '--categories [array]', Array, 'Limit selection by categories. Example usage: "cat1.subcat1 cat2.subcat1.subsubcat1 .excludethis.subcat etc."'
  c.option '-d', '--download-method [string]', String, 'Override download method set in your active options.'
  c.option '-n', '--number [integer]', Integer, 'Override selection using random number generator by specifying fixed number.'
  c.option '-o', '--options [string]', String, 'Specify custom path to your options file (default: options set in "options.yml").'
  c.option '-p', '--player [string]', String, 'Override which player to use.'
  c.option '-r', '--rng [string]', String, 'Override random number generation method specified in your options.yml file. Possible values: "hwrng", "random.org", "rand-hwrng-seed", "rand". Default value: "hwrng".'
  c.option '-s', '--sources [string]', String, 'Specify custom path to your sources.yml file (default: "sources.yml").'
  c.action do |args, opts|
    command_run(args, opts)
  end
end

command :set do |c|
  c.syntax = 'Budík.rb set [options]'
  c.summary = 'Set alarm.'
  c.description = 'Set alarm using systemd timers, cron or schtasks.'
  c.action do |args, opts|
    command_set(args, opts)
  end
end

command :sources do |c|
  c.syntax = 'Budík.rb sources [options]'
  c.summary = 'Manage source(s).'
  c.description = 'Add, list, remove, or pre-download source(s).'
  c.option '-a', '--add [string]', String, 'Add new source. Usage: add "path|{name: name, category: category, path: path}". Name and category are optional (default: no name, category "default").'
  c.option '-l', '--list [string]', String, 'List sources. Can be restricted by categories. DEFAULT option. Usage: list "all|category.subcategory .exclude.this". Default: list "all"'
  c.option '-r', '--remove [string]', String, 'Remove source or category. Usage: remove "path|name|number|{category: category, number: number}|category". Default: does nothing.'
  c.option '-d', '--download [string]', String, 'Downloads source(s). Usage: download "all|number|{category: category, number: number}|path|name". Default: download "all".'
  c.action do |args, opts|
    command_sources(args, opts)
  end
end

alias_command :test, :'run', '--trace'

command :translate do |c|
  c.syntax = 'Budík.rb translate [options]'
  c.summary = 'Translate app.'
  c.description = 'Translate application to your language using interactive mode.'
  c.action do |args, opts|
    command_translate(args, opts)
  end
end

command :unset do |c|
  c.syntax = 'Budík.rb unset [options]'
  c.summary = 'Unset alarm.'
  c.description = 'Unset alarm.'
  c.action do |args, opts|
    command_unset(args, opts)
  end
end

command :update do |c|
  c.syntax = ''
  c.summary = ''
  c.description = ''
  c.action do |args, opts|
    command_update(args, opts)
  end
end
