#!/usr/bin/env ruby
# encoding: Windows-1252

require 'commander/import'
require 'fileutils'
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

global_option('-C', '--categories [array]', 'Limit selection by categories. Example usage: "cat1-subcat1 cat2-subcat1-subsubcat1 etc."') {}
global_option('-D', '--download-method [string]', 'Override download method set in your options.yml file.') {}
global_option('-N', '--number [integer]', 'Specify fixed number of source to select.') {}
global_option('-O', '--options [string]', 'Specify custom path to your options.yml file (default: "./options.yml").') {}
global_option('-P', '--player [string]', 'Override which player to use.') {}
global_option('-R', '--rng [string]', 'Override random number generation method specified in your options.yml file. Possible values: "hwrng", "random.org", "rand-hwrng-seed", "rand". Default value: "hwrng".') {}
global_option('-S', '--sources [string]', 'Specify custom path to your sources.yml file (default: "./sources.yml").') {}

command :add do |c|
    c.syntax = 'Budík.rb add [args]'
    c.summary = 'Add media source.'
    c.description = 'Adds new media source(s) to your sources.yml file.'
    c.action do |args, options|
    end
end

command :config do |c|
    c.syntax = 'Budík.rb config [options]'
    c.summary = 'Edit program configuration.'
    c.description = 'Interactive way to edit your config.yml file.'
    c.option '--new [string]', String, 'Create new configuration file with specified name (name => options-name.yml). Default: reset options.yml.'
    c.option '--edit [string]', String, 'Edit configuration file with specified name (name => options-name.yml). Default: edit options.yml.'
    c.option '--set [string]', String, 'Set configuration file with specified name (name => options-name.yml) as default. Default: set options.yml as default.'
    c.option '--delete [string]', String, 'Delete configuration file with specified name (name => options-name.yml). Default: does nothing.'
    c.action do |args, opts|
        command_config(args, opts)
    end
end

command :download do |c|
    c.syntax = 'Budík.rb download [options]'
    c.summary = 'Pre-download remote source(s).'
    c.description = 'Pre-download all remote sources or a specified remote source.'
    c.option '--number [integer]', Integer, 'Specify fixed number of source to select'
    c.action do |args, opts|
        command_download(args, opts)
    end
end

command :run do |c|
    c.syntax = 'Budík.rb run [options]'
    c.summary = 'DEFAULT: Runs alarm.'
    c.description = 'Runs alarm with specified options. CLI options > options.yml.'
    c.option '--categories [array]', Array, 'Limit selection by categories. Example usage: "cat1.subcat1 cat2.subcat1.subsubcat1 .excludethis.subcat etc."'
    c.option '--number [integer]', Integer, 'Override selection using random number generator by specifying fixed number.'
    c.option '--options [string]', String, 'Specify custom path to your options.yml file (default: "./options.yml").'
    c.option '--rng [string]', String, 'Override random number generation method specified in your options.yml file. Possible values: "hwrng", "random.org", "rand-hwrng-seed", "rand". Default value: "hwrng".'
    c.option '--sources [string]', String, 'Specify custom path to your sources.yml file (default: "./sources.yml").'
    c.action do |args, opts|
        command_run(args, opts)
    end
end

# TODO: command :set

default_command :run

def command_config(args, opts)
    Options::load_config(opts.options)

    new = opts.new != nil
    edit = opts.edit != nil
    set = opts.set != nil
    delete = opts.delete != nil

    none = !new && !edit && !set && !delete

    if none
        config_menu
    elsif new && !edit && !set && !delete
        config_new(opts.new == true ? nil : opts.new)
    elsif edit && !new && !set && !delete
        config_edit(opts.edit == true ? nil : opts.edit)
    elsif set && !new && !edit && !delete
        config_set(opts.set == true ? nil : opts.set)
    elsif delete && !new && !edit && !set
        config_delete(opts.delete == true ? nil : opts.delete)
    else
        puts "Please use only one of the options new, edit, set, delete, or none. This doesn't include global options"
    end
end

def command_download(args, opts)
=begin
    options =.yml.parse(File.read(opts.options ? opts.options : "./options.yml"))

    if options["sources"]["download"]["method"] == "remove"
        puts "WARNING: Download method in your options.yml is set to \"remove\", downloaded source(s) will be deleted after use. Do you want to change download method to \"save\"? (y/n): "
        change = gets.chomp

        while true do
            case change
            when "y"
                options["sources"]["download"]["method"] = "save"
                sources = opts.sources ? opts.sources : options["sources"]["path"]
                File.open(sources, "w") do |f|
                    f.write.yml.pretty_generate(options))
                end
                break
            when "n"
                break
            else
                puts "Invalid choice. Use \"y\" or \"n\"."
                next
            end
        end
    end
    opts.number ? Sources::prepare_source(Sources::get_source_by_number(opts.number), options) : Sources::prepare_all(options)
=end
end

def command_run(args, opts)
        options = Options::load_options(opts.options)
        Sources::load_sources(opts.sources ? opts.sources : options["sources"]["path"], opts.categories ? Sources::parse_category_mods(opts.categories) : (options["sources"]["categories"] == "all" ? nil : Sources::parse_category_mods(options["sources"]["categories"])))
        number = opts.number ? opts.number : rng(options["rng"], Sources::sources_count , opts.rng ? opts.rng : nil)

        unless options["os"] == "windows"
            Devices::storage_get(options["sources"]["download"])
            Devices::storage_mount
        end
        source = Sources::prepare_source(Sources::get_source_by_number(number), options)
        Player::get(options["player"])
        Player::play(source)
        Sources::delete(source, options["os"]) if options["sources"]["download"]["method"] == "remove"
        unless options["os"] == "windows"
            Devices::storage_unmount
            Devices::storage_sleep
        end
end
