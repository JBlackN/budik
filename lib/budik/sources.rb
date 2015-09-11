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

    def parse(sources, mods = nil)
      sources.each do |item|
        if item.is_a? Array
          normalized_item = { name: '', category: ['default'], path: []}
          item.each do |subitem|
            normalized_item[:name] += (subitem + ' + ')
            normalized_item[:path] << subitem
          end
          3.times { normalized_item[:name].chop! }
        elsif item.is_a? Hash
          normalized_item = {}
          normalized_item[:name] = item['name']
          normalized_item[:category] = item['category'] ? item['category'] : ['default']
          normalized_item[:path] = item['path']
        elsif item.is_a? String
          normalized_item = { name: item, category: ['default'], path: item }
        else # TODO: test
          fail Config.instance.lang.sources.invalid_item item.to_s
        end

        @sources << normalized_item
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
