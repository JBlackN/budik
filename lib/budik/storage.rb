# = storage.rb
# This file contains methods for managing downloaded sources.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 20, 2015

module Budik
  # 'Storage' class downloads and manages media sources/items.
  class Storage
    include Singleton

    # Loads sources, download directory and download method.
    def initialize
      @sources = Sources.instance.sources
      dir = Config.instance.options['sources']['download']['dir']
      @dir = File.expand_path(dir) + '/'
      @method = Config.instance.options['sources']['download']['method']
    end

    # Gets sources, download directory and download method.
    attr_accessor :sources, :dir, :method

    # Downloads specified source or all sources.
    #
    # - *Args*:
    #   - +source+ -> Source to download (Hash).
    #
    def download_sources(source = nil)
      if source
        source[:path].each do |path|
          download_youtube(YouTubeAddy.extract_video_id(path))
        end
      else
        @sources.each { |src| download_sources(src) }
      end
    end

    # Downloads video from YouTube by ID with specified options.
    #
    # - *Args*:
    #   - +id+ -> YouTube video ID (String).
    #
    def download_youtube(id)
      return unless id && !File.file?(@dir + id + '.mp4')

      # TODO: Update youtube-dl if fail
      # TODO: username + password
      options = { output: @dir + '%(id)s.%(ext)s',
                  format: 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4',
                  playlist: false }
      YoutubeDL.download id, options
    end

    # Gets downloaded item's location.
    #
    # - *Args*:
    #   - +item+ -> Item to locate (String).
    # - *Returns*:
    #   - Path to downloaded file.
    #   - Unaltered path if streaming or if the item is local.
    #
    def locate_item(item)
      return item if @method == 'stream'
      is_url = (item =~ /\A#{URI.regexp(%w(http https))}\z/)
      is_url ? @dir + YouTubeAddy.extract_video_id(item) + '.mp4' : item
    end

    # Removes specified source or all sources.
    #
    # - *Args*:
    #   - +source+ -> Source to remove (Hash).
    #
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
