#!/usr/bin/env ruby
# encoding: Windows-1252

require 'awesome_print'
require 'commander/import'
require 'fileutils'
require 'json'
require 'uri'
require 'ya2yaml'
require 'yaml'

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

# TODO: command :set

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

def command_config(args, opts)
  Options::load_config(opts.options)

  new = opts.new != nil
  edit = opts.edit != nil
  set = opts.set != nil
  delete = opts.delete != nil
  app = opts.app != nil

  none = !new && !edit && !set && !delete && !app

  if none
    config_menu
  elsif new && !edit && !set && !delete && !app
    config_new(opts.new ? nil : opts.new)
  elsif edit && !new && !set && !delete && !app
    config_edit(opts.edit ? nil : opts.edit)
  elsif set && !new && !edit && !delete && !app
    config_set(opts.set ? nil : opts.set)
  elsif delete && !new && !edit && !set && !app
    config_delete(opts.delete ? nil : opts.delete)
  elsif app && !new && !edit && !set && !delete
    config_app
  else
    puts "Please use only one or none of the options new, edit, set, delete. This doesn't include global options."
  end
end

def command_run(args, opts)
  options = Options::load_config(opts.options)
  Sources::load_sources(opts.sources ? opts.sources : options['sources']['path'], opts.categories ? Sources::parse_category_mods(opts.categories) : (options['sources']['categories'] == 'all' ? nil : Sources::parse_category_mods(options['sources']['categories'])))
  number = opts.number ? opts.number : rng(options['rng'], Sources::sources_count , opts.rng ? opts.rng : nil)

  unless options['os'] == 'windows'
    Devices::storage_get(options['sources']['download'])
    Devices::storage_mount
  end
  source = Sources::prepare_source(Sources::get_source_by_number(number), options)
  Player::get(options['player'])
  Player::play(source)
  Sources::delete(source, options['os']) if options['sources']['download']['method'] == 'remove'
  unless options['os'] == 'windows'
    Devices::storage_unmount
    Devices::storage_sleep
  end
end

def command_sources(args, opts)
  options = Options::load_config(opts.options)

  add = opts.add != nil
  list = opts.list != nil
  remove = opts.remove != nil
  download = opts.download != nil

  none = !add && !list && !remove && !download

  if none || (list && !add && !remove && !download)
    sources = Sources::load_sources(opts.sources ? opts.sources : options['sources']['path'], opts.list.is_a?(String) && opts.list != 'all' ? Sources::parse_category_mods(opts.list) : nil)
    ap sources
  elsif add && !list && !remove && !download
    sources = YAML.load_file(opts.sources ? opts.sources : options['sources']['path'])
    if opts.add.is_a? String
      new_item = YAML.load(opts.add)
      if new_item.is_a? String
        sources['default'] = [] unless sources['default'].is_a? Array
        sources['default'] << new_item
      elsif new_item.is_a? Hash
        unless new_item.has_key? 'path'
          puts 'Please specify path.'
          return
        end

        if new_item.has_key? 'category'
          category = new_item['category']
          if category.include? ' ' || category[0] == '.'
            fail 'Invalid category.'
          else
            sub_sources = sources
            category.split('.').each do |c|
              begin
                sub_sources = sub_sources[c]
              rescue
                sub_sources[c] = Hash.new
                sub_sources = sub_sources[c]
              end
            end
            new_item.delete('category')
          end
        end

        if new_item.has_key? 'name'
          sub_sources << new_item
        else
          sub_sources << new_item['path']
        end
      end

      File.open(opts.sources ? opts.sources : options['sources']['path'], 'w') { |f| f.puts sources.ya2yaml(syck_compatible: true) }
    else
      puts 'Please specify what to add.'
    end
  elsif remove && !add && !list && !download
    # TODO
    puts 'TODO: Sources::remove_source'
  elsif download && !add && !list && !remove
    if opts.download == 'all' || opts.download == true
      # TODO: Options DL method check
      # TODO: Create dir if not exists (NO NEED)
      Sources::load_sources(opts.sources ? opts.sources : options['sources']['path'], nil)
      Sources::prepare_all(options)
    elsif opts.download.to_i.is_a? Integer
      # TODO
    elsif opts.download.is_a? String
      # TODO
    elsif opts.download.is_a? Hash
      # TODO
    end
  else
    puts "Please use only one or none of the options add, list, remove, or download. This doesn't include global options."
  end
end
