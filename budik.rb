#!/usr/bin/env ruby
# encoding: Windows-1252

require 'commander/import'
require 'json'
require 'uri'
require './config.rb'
require './devices.rb'
require './rng.rb'
require './sources.rb'
#require './alarm.rb'

program :name, 'Budík.rb'
program :version, '0.0.1'
program :description, 'Alarm clock which randomly plays a song or a video from YouTube or your local collection.'

global_option('-c', '--categories [array]', 'Limit selection by categories. Example usage: "cat1-subcat1 cat2-subcat1-subsubcat1 etc."') {}
global_option('-n', '--number [integer]', 'Specify fixed number of source to select.') {}
global_option('-o', '--options [string]', 'Specify custom path to your options.json file (default: "./options.json").') {}
global_option('-r', '--rng [string]', 'Override random number generation method specified in your options.json file. Possible values: "hwrng", "random.org", "rand-hwrng-seed", "rand". Default value: "hwrng".') {}
global_option('-s', '--sources [string]', 'Specify custom path to your sources.json file (default: "./sources.json").') {}

command :config do |c|
    c.syntax = 'Budík.rb config [options]'
    c.summary = 'Edit program configuration.'
    c.description = 'Interactive way to edit your config.json file.'
    c.action do |args, options|
        config
    end
end

command :download do |c|
  c.syntax = 'Budík.rb download [options]'
  c.summary = 'Pre-download remote source(s).'
  c.description = 'Pre-download all remote sources or a specified remote source.'
  c.option '--number [integer]', Integer, 'Specify fixed number of source to select'
  c.action do |args, opts|
        options = JSON.parse(File.read(opts.options ? opts.options : "./options.json"))

        if options["sources"]["download"]["method"] == "remove"
            puts "WARNING: Download method in your options.json is set to \"remove\", downloaded source(s) will be deleted after use. Do you want to change download method to \"save\"? (y/n): "
            change = gets.chomp

            while true do
                case change
                when "y"
                    options["sources"]["download"]["method"] = "save"
                    sources = opts.sources ? opts.sources : options["sources"]["path"]
                    File.open(sources, "w") do |f|
                        f.write(JSON.pretty_generate(options))
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
  end
end

command :run do |c|
    c.syntax = 'Budík.rb run [options]'
    c.summary = 'DEFAULT: Runs alarm.'
    c.description = 'Runs alarm with specified options. CLI options > options.json.'
    c.option '--categories [array]', Array, 'Limit selection by categories. Example usage: "cat1.subcat1 cat2.subcat1.subsubcat1 .excludethis.subcat etc."'
    c.option '--number [integer]', Integer, 'Override selection using random number generator by specifying fixed number.'
    c.option '--options [string]', String, 'Specify custom path to your options.json file (default: "./options.json").'
    c.option '--rng [string]', String, 'Override random number generation method specified in your options.json file. Possible values: "hwrng", "random.org", "rand-hwrng-seed", "rand". Default value: "hwrng".'
    c.option '--sources [string]', String, 'Specify custom path to your sources.json file (default: "./sources.json").'
    c.action do |args, opts|
        options = JSON.parse(File.read(opts.options ? opts.options : "./options.json"))
        Sources::load_sources(opts.sources ? opts.sources : options["sources"]["path"], opts.categories ? parse_category_mods(opts.categories) : nil)
        number = opts.number ? opts.number : rng(options["rng"], Sources::sources_count , opts.rng ? opts.rng : nil)
        Devices::storage_get(options["sources"]["download"])
        Devices::storage_mount
        source = Sources::prepare_source(Sources::get_source_by_number(number), options)
        Player::get(options["player"])
        Player::play(source)
        Devices::storage_unmount
        Devices::storage_sleep
    end
end

# TODO: command :set

default_command :run

def parse_category_mods(mod_string)
    parsed_mods = Hash.new
    parsed_mods[:adds] = []
    parsed_mods[:rms] = []

    mods = mod_string.split(" ")
    mods.each do |m|
        mod = m.split(".")
        unless mod.first == ""
            parsed_mods[:adds] << mod
        else
            mod.shift
            parsed_mods[:rms] << mod
        end
    end
    parsed_mods
end
