# = player.rb
# This file contains methods for managing media players.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 20, 2015

module Budik
  # 'Player' class handles communication between app and media players.
  class Player
    include Singleton

    # Sets player and loads its options.
    def initialize
      player_options = Config.instance.options['player']
      @player = player_options['player']

      if @player == 'omxplayer'
        @player_options = player_options['omxplayer']
      else
        @player_options = player_options['vlc']
      end
    end

    # Gets current player and its options.
    attr_accessor :player, :player_options

    # Plays a source using currently set player.
    #
    # - *Args*:
    #   - +source+ -> Source to play (Hash).
    #
    def play(source)
      if @player == 'omxplayer'
        omxplayer(source)
      else
        vlc(source)
      end
    end

    # Plays a source using omxplayer.
    #
    # - *Args*:
    #   - +source+ -> Source to play (Hash).
    #
    def omxplayer(source)
      source[:path].each_with_index do |item, index|
        Open3.popen3(omx_build_command(item)) do |i, _o, _e, _t|
          omx_volume_control(i) if index == 0
        end
      end
    end

    # Builds omxplayer's command with required parameters.
    #
    # - *Args*:
    #   - +item+ -> Item to play (path, String).
    #
    def omx_build_command(item)
      command = @player_options['path']
      args = '--vol ' + @player_options['default_volume'].to_s
      command + ' ' + args + ' "' + Storage.instance.locate_item(item) + '"'
    end

    # Fades in volume using omxplayer's volup command.
    #
    # - *Args*:
    #   - +i+ -> Stdin object.
    #
    def omx_volume_control(i)
      7.times do
        sleep(@player_options['volume_step_secs'])
        i.print '+'
      end
      i.close
    end

    # Plays a source using vlc.
    #
    # - *Args*:
    #   - +source+ -> Source to play (Hash).
    #
    def vlc(source)
      vlc_pid = spawn(vlc_build_command(source))
      sleep(@player_options['wait_secs_after_run'])
      vlc_volume_control(vlc_rc_connect)

      Process.wait(vlc_pid)
    end

    # Builds VLC's command with required parameters.
    #
    # - *Args*:
    #   - +source+ -> Source to play (Hash).
    #
    def vlc_build_command(source)
      vlc_path = Marshal.load(Marshal.dump(@player_options['path']))
      vlc_path.gsub!(/(^|$)/, '"') if vlc_path =~ /\s/

      args = vlc_build_args
      files = vlc_cmd_add_items(source)

      vlc_path + args[:rc] + args[:volume] + args[:fullscreen] + files
    end

    # Builds list of options/arguments fo VLC command
    def vlc_build_args
      rc_host = @player_options['rc_host']
      rc_port = @player_options['rc_port']
      rc = ' --extraintf rc --rc-host ' + rc_host + ':' + rc_port.to_s

      volume = ' --volume-step ' + @player_options['volume_step'].to_s
      fullscreen = @player_options['fullscreen'] ? ' --fullscreen ' : ' '

      { rc: rc, volume: volume, fullscreen: fullscreen }
    end

    # Parses source and adds its items to the VLC command.
    # Adds 'vlc://quit' to automatically quit VLC after play is over.
    #
    # - *Args*:
    #   - +source+ -> Source to play (Hash).
    #
    def vlc_cmd_add_items(source)
      files = ''
      source[:path].each do |item|
        item_path = Storage.instance.locate_item(item).gsub(%r{^/}, '')
        files += (vlc_cmd_item_prefix(item_path) + item_path + '" ')
      end
      files += 'vlc://quit'
    end

    # Adds 'file:///' prefix to local file paths so VLC plays them
    # correctly.
    #
    # - *Args*:
    #   - +item_path+ -> Path to item.
    #
    def vlc_cmd_item_prefix(item_path)
      is_url = (item_path =~ /\A#{URI.regexp(%w(http https))}\z/)
      is_url ? '"' : '"file:///'
    end

    # Makes a connection to VLC's remote control interface.
    # FIXME: Possible infinite loop
    def vlc_rc_connect
      rc_host = @player_options['rc_host']
      rc_port = @player_options['rc_port']
      loop do
        begin
          rc = TCPSocket.open(rc_host, rc_port)
          return rc
        rescue
          next
        end
      end
    end

    # Fades in volume using VLC's remote control interface.
    #
    # - *Args*:
    #   - +rc+ -> IO object (returned by TCPSocket.open).
    #
    def vlc_volume_control(rc)
      rc.puts 'volume ' + @player_options['default_volume'].to_s
      128.times do
        sleep(@player_options['volume_fadein_secs'])
        rc.puts 'volup ' + @player_options['volume_step'].to_s
      end
    end
  end
end
