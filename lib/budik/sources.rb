# = sources.rb
# This file contains methods for parsing sources and category modifiers.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 20, 2015

module Budik
  # 'Sources' class loads and parses media sources file.
  class Sources
    include Singleton

    # Initializes sources instance variable and strings in currently set
    # language.
    def initialize
      @sources = []
      @strings = Config.instance.lang.sources
    end

    # Gets sources
    attr_accessor :sources

    # Applies category modifiers.
    #
    # - *Args*:
    #   - +mods+ -> Category modifiers (Hash).
    #
    def apply_mods(mods)
      @sources.keep_if do |source|
        mods[:adds].any? { |mod| apply_mods_check(source[:category], mod) }
      end

      @sources.delete_if do |source|
        mods[:rms].any? { |mod| apply_mods_check(source[:category], mod) }
      end
    end

    # Checks if mod applies to category.
    #
    # - *Args*:
    #   - +category+ -> Category to be checked (Array).
    #   - +mod+ -> Modifier to be checked (Array).
    # - *Returns*:
    #   - true or false
    #
    def apply_mods_check(category, mod)
      mod_len = mod.length - 1
      cat_len = category.length - 1
      len = mod_len <= cat_len ? mod_len : cat_len

      map = category[0..len].zip(mod[0..len]).map { |c, m| c == m }
      !map.include? false
    end

    # Returns total count of sources
    def count
      @sources.length
    end

    # Returns source by number.
    #
    # - *Args*:
    #   - +number+ -> Fixnum.
    #
    def get(number)
      @sources[number]
    end

    # Normalizes item.
    #
    # - *Args*:
    #   - +item+ -> Item to normalize (Array, Hash or String).
    #   - +category+ -> Item's category (Array).
    # - *Returns*:
    #   - Normalized source (Hash).
    # - *Raises*:
    #   - +RuntimeError+ -> If item is not Array, Hash or String.
    #
    def normalize(source, category)
      case source
      when Array
        normalize_multiple_items(source, category)
      when Hash
        normalize_named_source(source, category)
      when String
        normalize_unnamed_source(source, category)
      else
        fail @strings.invalid_format
      end
    end

    # Normalizes unnamed source with multiple items.
    #
    # - *Args*:
    #   - +source+ -> Source to normalize (Array).
    #   - +category+ -> Source's category (Array).
    # - *Returns*:
    #   - Normalized source (Hash).
    #
    def normalize_multiple_items(source, category)
      { name: source.join(' + '), category: category, path: source }
    end

    # Normalizes named source.
    #
    # - *Args*:
    #   - +source+ -> Source to normalize (Hash).
    #   - +category+ -> Source's category (Array).
    # - *Returns*:
    #   - Normalized source (Hash).
    #
    def normalize_named_source(source, category)
      { name: source.keys[0], category: category, path: source.values[0] }
    end

    # Normalizes unnamed source with single item.
    #
    # - *Args*:
    #   - +source+ -> Source to normalize (String).
    #   - +category+ -> Source's category (Array).
    # - *Returns*:
    #   - Normalized source (Hash).
    #
    def normalize_unnamed_source(source, category)
      { name: source, category: category, path: [] << source }
    end

    # Parses sources' categories.
    #
    # - *Args*:
    #   - +sources+ -> Sources loaded from YAML (Hash).
    #   - +current_category+ -> Source's category (Array).
    # - *Raises*:
    #   - +RuntimeError+ -> If category's contents is not Array nor Hash.
    #
    def parse(sources, current_category = [])
      sources.each do |category, contents|
        case contents
        when Hash
          parse(contents, current_category + ([] << category))
        when Array
          parse_category(contents, current_category + ([] << category))
        else
          fail @strings.invalid_format
        end
      end
    end

    # Parses category contents.
    #
    # - *Args*:
    #   - +contents+ -> Category's contents (Array).
    #   - +category+ -> Source's category (Array).
    #
    def parse_category(contents, category)
      contents.each { |source| @sources << normalize(source, category) }
    end

    # Parses string of category modifiers into two arrays (adds, rms).
    #
    # - *Args*:
    #   - +mods+ -> Category modifiers (String).
    # - *Returns*:
    #   - Parsed modifiers (Hash).
    #
    def parse_mods(mods)
      parsed_mods = { adds: [], rms: [] }

      mods.split(' ').each do |mod|
        if mod.split('.').first.empty?
          parsed_mods[:rms] << mod.split('.').drop(1)
        else
          parsed_mods[:adds] << mod.split('.')
        end
      end

      parsed_mods
    end
  end
end
