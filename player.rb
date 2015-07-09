require 'open3'

class Player
    @@player = "omxplayer"
    @@player_options = nil
    @@player_set = false

    def self.get(player_options)
        unless @@player_set
            @@player = player_options["player"] unless player_options["player"] == "omxplayer"
            case @@player
            when "vlc"
                @@player_options = player_options["vlc"]
            else
                @@player_options = player_options["omxplayer"]
            end
            @@player_set = true
        end
    end

    def self.play(source)
        unless @@player == "vlc"
            omxplayer(source)
        else
            vlc(source)
        end
    end

    def self.omxplayer(source)
        source.each do |item|
            cmd = 'omxplayer --vol ' + player_options["defaultVolume"].to_s + ' ' + item["path"]
            Open3.popen3(cmd) do |i, o, e, t|
                (1..7).each do |c|
                    sleep(@@player_options["volumeStepSecs"])
                    i.puts "volup"
                end
                i.close
            end
        end
    end

    def self.vlc(source)
    end
end
