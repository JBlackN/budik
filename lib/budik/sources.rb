module Budik
  # 'Sources' class loads and parses media sources file.
  class Sources
    include Singleton

    def initialize
      @sources = []
    end

    attr_accessor :sources

    def apply_mods(mods)
      @sources.keep_if do |source|
        mods[:adds].any? { |mod| apply_mods_check(source[:category], mod) }
      end

      @sources.delete_if do |source|
        mods[:rms].any? { |mod| apply_mods_check(source[:category], mod) }
      end
    end

    def apply_mods_check(category, mod)
      mod_len = mod.length - 1
      cat_len = category.length - 1
      len = mod_len <= cat_len ? mod_len : cat_len

      map = category[0..len].zip(mod[0..len]).map { |c, m| c == m }
      !map.include? false
    end

    def count
      @sources.length
    end

    def get(number)
      @sources[number]
    end

    def normalize(item, category)
      case item
      when Array
        normalize_multiple_items(item, category)
      when Hash
        normalize_named_source(item, category)
      when String
        normalize_unnamed_source(item, category)
      else
        fail 'Invalid item in sources' # TODO
      end
    end

    def normalize_multiple_items(source, category)
      { name: source.join(' + '), category: category, path: source }
    end

    def normalize_named_source(source, category)
      { name: source.keys[0], category: category, path: source.values[0] }
    end

    def normalize_unnamed_source(source, category)
      { name: source, category: category, path: [] << source }
    end

    def parse(sources, mods = nil, current_category = [])
      sources.each do |category, contents|
        case contents
        when Hash
          parse(contents, mods, current_category + ([] << category))
        when Array
          parse_category(contents, current_category + ([] << category))
        else
          fail 'Invalid sources format' # TODO
        end
      end
    end

    def parse_category(contents, category)
      contents.each { |item| @sources << normalize(item, category) }
    end

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
