require 'open3'
require 'socket'

class Player
  @@player = 'omxplayer'
  @@player_options = nil
  @@player_set = false

  def self.get(player_options)
    unless @@player_set
      @@player = player_options['player'] unless player_options['player'] == 'omxplayer'
      case @@player
      when 'vlc'
        @@player_options = player_options['vlc']
      else
        @@player_options = player_options['omxplayer']
      end
      @@player_set = true
    end
  end

  def self.play(source)
    unless @@player == 'vlc'
      omxplayer(source)
    else
      vlc(source)
    end
  end

  def self.omxplayer(source)
    source.each do |item|
      cmd = @@player_options['path'] + ' --vol ' + @@player_options['defaultVolume'].to_s + ' ' + item['path']
      Open3.popen3(cmd) do |i, o, e, t|
        (1..7).each do |c|
          sleep(@@player_options['volumeStepSecs'])
          i.puts 'volup'
        end
        i.close
      end
    end
  end

  def self.vlc(source)
    cmd = '"' + @@player_options['path'] + '" --extraintf rc --rc-host ' + @@player_options['rcHost'] + ':' + @@player_options['rcPort'].to_s + ' --volume-step ' + @@player_options['volumeStep'].to_s + (@@player_options['fullscreen'] ? ' --fullscreen ' : ' ')
    source.each do |item|
      cmd += ('"file:///' + item['path'] + '" ')
    end
    cmd += 'vlc://quit'
    vlc_pid = spawn(cmd)
    sleep(@@player_options['waitSecsAfterVlcRuns'])

    while true do
      begin
        rc = TCPSocket.open(@@player_options['rcHost'], @@player_options['rcPort'])
        break
      rescue
        next
      end
    end

    rc.puts 'volume ' + @@player_options['defaultVolume'].to_s
    (1..128).each do |i|
      sleep(@@player_options['volumeFadeInSecs'])
      rc.puts 'volup ' + @@player_options['volumeStep'].to_s
    end

    Process.wait(vlc_pid)
  end
end
