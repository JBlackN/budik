module Budik
  # 'Player' class handles communication between app and media players.
  class Player
    include Singleton

    def initialize
      player_options = Config.instance.options['player']
      @player = player_options['player']

      if @player == 'omxplayer'
        @player_options = player_options['omxplayer']
      else
        @player_options = player_options['vlc']
      end
    end

    attr_accessor :player_options

    def play(source)
      if @player == 'omxplayer'
        omxplayer(source)
      else
        vlc(source)
      end
    end

    def omxplayer(source)
      source[:path].each do |item|
        Open3.popen3(omx_build_command(item)) do |i, _o, _e, _t|
          7.times do
            sleep(@player_options['volume_step_secs'])
            i.puts 'volup'
          end
          i.close
        end
      end
    end

    def omx_build_command(item)
      command = @player_options['path']
      args = '--vol ' + @player_options['default_volume'].to_s
      command + ' ' + args + ' ' + Sources.instance.locate_item(item)
    end

    def vlc(source)
      vlc_pid = spawn(vlc_build_command(source))
      sleep(@player_options['wait_secs_after_run'])
      vlc_volume_control(vlc_rc_connect)

      Process.wait(vlc_pid)
    end

    def vlc_build_command(source)
      vlc_path = @player_options['path']
      vlc_path.gsub!(/^/, '"').gsub!(/$/, '"') if vlc_path =~ /\s/

      args = vlc_build_args
      files = vlc_cmd_add_items(source)

      vlc_path + args[:rc] + args[:volume] + args[:fullscreen] + files
    end

    def vlc_build_args
      rc_host = @player_options['rc_host']
      rc_port = @player_options['rc_port']
      rc = ' --extraintf rc --rc-host ' + rc_host + ':' + rc_port.to_s

      volume = ' --volume-step ' + @player_options['volume_step'].to_s
      fullscreen = @player_options['fullscreen'] ? ' --fullscreen ' : ' '

      { rc: rc, volume: volume, fullscreen: fullscreen }
    end

    def vlc_cmd_add_items(source)
      files = ''
      source[:path].each do |item|
        item_path = Sources.instance.locate_item(item).gsub(%r{^/}, '')
        files += ('"file:///' + item_path + '" ')
      end
      files += 'vlc://quit'
    end

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

    def vlc_volume_control(rc)
      rc.puts 'volume ' + @player_options['default_volume'].to_s
      128.times do
        sleep(@player_options['volume_fadein_secs'])
        rc.puts 'volup ' + @player_options['volume_step'].to_s
      end
    end
  end
end
