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
      source[:path].each do |item| # TODO: ensure path is always array
        command = @player_options['path'] + ' --vol ' + @player_options['defaultVolume'].to_s + ' ' + item
        Open3.popen3(command) do |i, o, e, t|
          7.times do
            sleep(@player_options['volumeStepSecs'])
            i.puts 'volup'
          end
          i.close
        end
      end
    end

    def vlc(source)
      vlc_path = @player_options['path'].gsub(' ', '\\ ')
      rc = @player_options['rcHost'] + ':' + @player_options['rcPort'].to_s
      command = vlc_path + ' --extraintf rc --rc-host ' + rc + ' --volume-step ' + @player_options['volumeStep'].to_s + (@player_options['fullscreen'] ? ' --fullscreen ' : ' ')

      source[:path].each do |item|
        command += ('"file:///' + item + '" ')
      end
      command += 'vlc://quit'
      vlc_pid = spawn(command)
      sleep(@player_options['waitSecsAfterVlcRuns'])

      while true do
        begin
          rc = TCPSocket.open(@player_options['rcHost'], @player_options['rcPort'])
          break
        rescue
          next
        end
      end

      rc.puts 'volume ' + @player_options['defaultVolume'].to_s
      (1..128).each do |i|
        sleep(@player_options['volumeFadeInSecs'])
        rc.puts 'volup ' + @player_options['volumeStep'].to_s
      end

      Process.wait(vlc_pid)
    end
  end
end
