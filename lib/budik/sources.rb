module Budik
  class Sources
    include Singleton

    def initialize
      @sources = []
    end

    attr_accessor :sources

    def apply_mods(mods)
      modified_sources = []

      @sources.each do |source|
        add = false
        mods[:adds].each do |mod|
          add = true if mod == (source[:category] & mod)
        end
        mods[:rms].each do |mod|
          add = false if mod == (source[:category] & mod)
        end
        modified_sources << source if add
      end

      @sources = modified_sources.uniq
    end

    def download(number = nil)
      dir = Config.instance.options['sources']['download']['dir']
      if number
        item = @sources[number]
        if item[:path].is_a? Array
          item[:path].each do |path|
            download_youtube(path, dir)
          end
        else
          download_youtube(item[:path], dir)
        end
      else
        @sources.each_with_index do |_source, index|
          download(index)
        end
      end
    end

    def download_youtube(address, dir)
      youtube_id = YouTubeAddy.extract_video_id(address)
      if youtube_id && !File.file?(dir + youtube_id + '.mp4')
        # TODO: Update youtube-dl if fail
        options = {
          # TODO: username + password
          output: dir + '%(id)s.%(ext)s',
          format: 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4',
          playlist: false
        }
        YoutubeDL.download address, options
      end
    end

    def normalize(item, category)
      normalized_item = { name: '', category: category, path: [] }

      if item.is_a? Array
        item.each do |subitem|
          normalized_item[:name] += (subitem + ' + ')
          normalized_item[:path] << subitem
        end
        3.times { normalized_item[:name].chop! }
      elsif item.is_a? Hash
        item.each do |name, paths|
          normalized_item[:name] = name
          paths.each do |path|
            normalized_item[:path] << path
          end
        end
      elsif item.is_a? String
        normalized_item[:name] = item
        normalized_item[:path] << item
      else
        fail 'Invalid item in sources' # TODO
      end

      return normalized_item
    end

    def parse(sources, mods = nil, current_category = [])
      sources.each do |category, contents|
        if contents.is_a? Hash
          parse(contents, mods, current_category + ([] << category))
        elsif contents.is_a? Array
          contents.each do |item|
            @sources << normalize(item, current_category + ([] << category))
          end
        else
          fail 'Invalid sources format' # TODO
        end
      end

      mods = (mods.is_a? String) ? parse_mods(mods) : mods
      apply_mods(mods) if mods
    end

    def parse_mods(mod_string)
      parsed_mods = { adds: [], rms: [] }

      mods = mod_string.split(' ')
      mods.each do |m|
        mod = m.split('.')
        if mod.first == ''
          mod.shift
          parsed_mods[:rms] << mod
        else
          parsed_mods[:adds] << mod
        end
      end

      return parsed_mods
    end
  end
end
