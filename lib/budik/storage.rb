module Budik
  # 'Storage' class downloads and manages media sources/items.
  class Storage
    include Singleton

    def initialize
      @sources = Sources.instance.sources
      dir = Config.instance.options['sources']['download']['dir']
      @dir = File.expand_path(dir) + '/'
      @method = Config.instance.options['sources']['download']['method']
    end

    attr_accessor :sources, :dir, :method

    def download_sources(source = nil)
      if source
        source[:path].each do |path|
          download_youtube(YouTubeAddy.extract_video_id(path))
        end
      else
        @sources.each { |src| download_sources(src) }
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

    def locate_item(item)
      return item if @method == 'stream'
      is_url = (item =~ /\A#{URI.regexp(%w(http https))}\z/)
      is_url ? @dir + YouTubeAddy.extract_video_id(item) + '.mp4' : item
    end

    def remove_sources(source = nil)
      return unless @method == 'remove'

      if source
        source[:path].each do |path|
          FileUtils.rm File.expand_path(locate_item(path)), force: true
        end
      else
        @sources.each { |src| remove_sources(src) }
      end
    end
  end
end
