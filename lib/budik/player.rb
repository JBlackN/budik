module Budik
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

    # TODO: source -> file path
    def play(source)
      if @player == 'omxplayer'
        omxplayer(source)
      else
        vlc(source)
      end
    end

    def omxplayer(source)
      source[:path].each do |item|
        command = @player_options['path'] + ' --vol ' + @player_options['default_volume'].to_s + ' ' + item
        Open3.popen3(command) do |i, o, e, t|
          7.times do
            sleep(@player_options['volume_step_secs'])
            i.puts 'volup'
          end
          i.close
        end
      end
    end

    def vlc(source)
      # TODO: is_url etc + vlc_path

      vlc_path = '"' + @player_options['path'] + '"'#.gsub(' ', '\\ ')
      rc = @player_options['rc_host'] + ':' + @player_options['rc_port'].to_s
      command = vlc_path + ' --extraintf rc --rc-host ' + rc + ' --volume-step ' + @player_options['volume_step'].to_s + (@player_options['fullscreen'] ? ' --fullscreen ' : ' ')

      source[:path].each do |item|
        is_url = (item =~ /\A#{URI::regexp(['http', 'https'])}\z/)
        item = Config.instance.options['sources']['download']['dir'] + YouTubeAddy.extract_video_id(item) + '.mp4' if is_url
        command += ('"file:///' + item + '" ')
      end
      command += 'vlc://quit'
      vlc_pid = spawn(command)
      sleep(@player_options['wait_secs_after_run'])

      while true do
        begin
          rc = TCPSocket.open(@player_options['rc_host'], @player_options['rc_port'])
          break
        rescue
          next
        end
      end

      rc.puts 'volume ' + @player_options['default_volume'].to_s
      (1..128).each do |i|
        sleep(@player_options['volume_fadein_secs'])
        rc.puts 'volup ' + @player_options['volume_step'].to_s
      end

      Process.wait(vlc_pid)
    end
  end
end
