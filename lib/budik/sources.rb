module Budik
  # 'Sources' class loads, parses and manages media sources/items.
  class Sources
    include Singleton

    def initialize
      @sources = []
      dir = Config.instance.options['sources']['download']['dir']
      @dir = File.expand_path(dir) + '/'
      @method = Config.instance.options['sources']['download']['method']
    end

    attr_accessor :sources, :dir, :method

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

    def download(source = nil)
      if source
        source[:path].each do |path|
          download_youtube(YouTubeAddy.extract_video_id(path))
        end
      else
        @sources.each { |src| download(src) }
      end
    end

    def download_youtube(id)
      return unless id && !File.file?(@dir + id + '.mp4')

      # TODO: Update youtube-dl if fail
      # TODO: username + password
      options = { output: @dir + '%(id)s.%(ext)s',
                  format: 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4',
                  playlist: false }
      YoutubeDL.download id, options
    end

    def get(number)
      @sources[number]
    end

    def locate_item(item)
      return item if @method == 'stream'
      is_url = (item =~ /\A#{URI.regexp(%w(http https))}\z/)
      is_url ? @dir + YouTubeAddy.extract_video_id(item) + '.mp4' : item
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

    def remove(source = nil)
      return unless @method == 'remove'

      if source
        source[:path].each do |path|
          FileUtils.rm File.expand_path(locate_item(path)), force: true
        end
      else
        @sources.each { |src| remove(src) }
      end
    end
  end
end
