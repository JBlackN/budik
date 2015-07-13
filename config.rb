def config_menu
    heading = "Budík.rb configuration"
    puts "\n" + heading
    (1..(heading.length + 1)).each { |x| print "=" }
    puts

    while true do
        choice = config_menu_prompt
        if choice =~ /^new( \S+)?$/
            if choice == "new"
                name = ask("Please enter name of your new configuration: ") do |q|
                    q.validate = /\S+/
                    q.default = "default"
                end
                config_new(name)
            else
                config_new(choice[4..choice.length])
            end
        elsif choice =~ /^edit( \S+)?$/
            if choice == "edit"
                name = ask("Please enter name of a configuration you want to edit: ") do |q|
                    q.validate = /\S+/
                    q.default = "default"
                end
                config_edit(name)
            else
                config_edit(choice[4..choice.length])
            end
        elsif choice =~ /^set( \S+)?$/
            if choice == "set"
                name = ask("Please enter name of a configuration you want to set as default: ") do |q|
                    q.validate = /\S+/
                    q.default = "default"
                end
                config_set(name)
            else
                config_set(choice[4..choice.length])
            end
        elsif choice =~ /^delete( \S+)?$/
            if choice == "delete"
                name = ask("Please enter name of a configuration you want to delete: ") do |q|
                    q.validate = /\S+/
                    q.default = "all except default"
                end
                config_delete(name)
            else
                config_delete(choice[4..choice.length])
            end
        elsif choice == "quit"
            break
        end
    end
end

def config_menu_prompt
    options_dir = Options::get_config("program", "options_dir")
    configs = Dir[options_dir + "*.yml"]
    if configs.empty?
        puts "You have no configurations available!"
    else
        puts "You have these configurations available:"
    end

    n = 0
    configs.each do |config|
        config.gsub!(/^(options|.+)\/options-(\S+)\.yml$/, '\2')
        puts "[#{n}]: #{config}"
        n += 1
    end

    choice = ask("What do you want to do (new [name], edit [name|number], set [name|number], delete [name|number], quit)? ") do |q|
        q.default = "quit"
        q.validate = /^((new|edit|set|delete)( \S+)?|quit)$/
    end

    if choice =~ /^(new|edit|set|delete)( \d+)$/
        choice.gsub!(/\d+/, configs[choice.gsub(/[^0-9]/, '').to_i])
    else
        choice
    end
end

def config_new(name)
    options_dir = Options::get_config("program", "options_dir")
    options_dir = options_dir[-1, 1] == "/" || options_dir[-1, 1] == "\\" ? options_dir : options_dir + "/"

    filename = name == nil ? (options_dir + "options-default.yml") : (options_dir + "options-" + name + ".yml")
    if !File.file?(filename) or agree("WARNING: This will reset your " + filename + " file. Do you want to proceed (y/n)? ")
        case agree("Do you want to use a template? ")
        when true
            template = config_use_template
            unless template == nil
                FileUtils.rm(filename) if File.file?(filename)
                FileUtils.cp(template, filename)
            end
        else
            config_new_wizard(filename)
        end
    end
end

def config_new_wizard(filename)
    heading = "NEW CONFIGURATION: " + filename
    puts "\n" + heading
    (1..heading.length).each { |x| print "=" }
    puts

    options = Hash.new

    options["os"] = ask("Which platform is this configuration intended for (windows, unix, rpi)? ") do |q|
        q.validate = /^windows|unix|rpi$/
        q.default = "rpi"
    end

    player_heading = "PLAYER CONFIGURATION:"
    puts "\n" + player_heading
    (1..player_heading.length).each { |x| print "-" }
    puts

    options["player"] = player_opts = Hash.new
    player_opts["player"] = ask("Please specify which player do you want to use (omxplayer, vlc): ") do |q|
        q.validate = /^omxplayer|vlc$/
        q.default = options["os"] == "rpi" ? "omxplayer" : "vlc"
    end

    case player_opts["player"]
    when "omxplayer"
        vlc_opts = config_player_defaults(:vlc)
        puts config_player_defaults(:omxplayer).to_yaml
        case agree("Do you want to use this default configuration for omxplayer (y/n)? ")
        when true
            omx_opts = config_player_defaults(:omxplayer)
        when false
            omx_opts = Hash.new
            omx_opts["default_volume"] = ask("Set omxplayer's default volume (in millibels, -10000-0): |-2100| ", Integer) do |q|
                q.in = -10000..0
                q.default = -2100
            end
            omx_opts["path"] = ask("Set omxplayer's command path: ") do |q|
                q.default = "omxplayer"
            end
            omx_opts["volume_step_secs"] = ask("Set omxplayer's volume step (pause between volume ups, in seconds, 0.001-600): |3| ", Float) do |q|
                q.in = 0.001..600
                q.default = 3
            end
        end
    when "vlc"
        omx_opts = config_player_defaults(:omxplayer)
        puts config_player_defaults(:vlc).to_yaml
        case agree("Do you want to use this default configuration for vlc (y/n)? ")
        when true
            vlc_opts = config_player_defaults(:vlc)
        when false
            vlc_opts = Hash.new
            vlc_opts["default_volume"] = ask("Set VLC player's default volume (0-1024: 64 = 25%, 128 = 50%, 192 = 75%, 256 = 100%)? |128| ", Integer) do |q|
                q.in = 0..1024
                q.default = 128
            end
            fullscreen = ask("Do you want to set VLC player to start in fullscreen (y/n)? ") do |q|
                q.validate = /^yes|no|y|n$/i
                q.default = "yes"
            end
            vlc_opts["fullscreen"] = (fullscreen.upcase.include? "Y") ? true : false
            vlc_opts["path"] = ask("Set VLC player's command path: ") do |q|
                q.default = "vlc"
            end
            vlc_opts["rc_host"] = ask("Set VLC player's remote control host: ") do |q|
                q.default = "localhost"
            end
            vlc_opts["rc_port"] = ask("Set VLC player's remote control port: |50000| ", Integer) do |q|
                q.in = 1...65536
                q.default = 50000
            end
            vlc_opts["volume_fade_in_secs"] = ask("Set VLC player's pause between volume ups, in seconds, 0.001-600) |0.125| ", Float) do |q|
                q.in = 0.001..600
                q.default = 0.125
            end
            vlc_opts["volume_step"] = ask("Set VLC player's volume step (1.0-256.0) |1.0| ") do |q|
                q.in = 1.0..256.0
                q.default = 1.0
            end
            vlc_opts["wait_secs_after_vlc_runs"] = ask("Set amount of seconds to give VLC time to start (0-600): |5| ", Integer) do |q|
                q.in = 0..600
                q.default = 5
            end
            vlc_opts["wait_secs_if_http_source"] = ask("Set amount of seconds to give VLC time to load remote source (0-600): |3| ", Integer) do |q|
                q.in = 0..600
                q.default = 3
            end
        end
    end
    player_opts["omxplayer"] = omx_opts
    player_opts["vlc"] = vlc_opts

    rng_heading = "RANDOM NUMBER GENERATION CONFIGURATION:"
    puts "\n" + rng_heading
    (1..rng_heading.length).each { |x| print "-" }
    puts

    options["rng"] = rng_opts = Hash.new
    rng_opts["method"] = ask("Please specify which random number generation method do you want to use (hwrng, random.org, rand-hwrng-seed, rand): ") do |q|
        q.validate = /^hwrng|random.org|rand-hwrng-seed|rand$/
        q.default = options["os"] == "windows" ? "random.org" : "hwrng"
    end

    case rng_opts["method"]
    when "hwrng"
        random_org_opts = config_rng_defaults(:random_org, options["os"])
        puts config_rng_defaults(:hwrng, options["os"]).to_yaml
        case agree("Do you want to use this default configuration for hwrng (y/n)? ")
        when true
            hwrng_opts = config_rng_defaults(:hwrng, options["os"])
        when false
            hwrng_opts = Hash.new
            hwrng_opts["source"] = ask("Set hwrng source: ") do |q|
                q.default = options["os"] == "windows" ? "" : (options["os"] == "rpi" ? "/dev/hwrng" : "/dev/random")
            end
        end
    when "random.org"
        hwrng_opts = config_rng_defaults(:hwrng, options["os"])
        puts config_rng_defaults(:random_org, options["os"]).to_yaml
        case agree("Do you want to use this default configuration for random.org (y/n)? ")
        when true
            random_org_opts = config_rng_defaults(:random_org, options["os"])
        when false
            random_org_opts = Hash.new
            random_org_opts["apikey"] = ask("Enter your random.org API key: ") do |q|
                q.default = ""
            end
        end
    else
        hwrng_opts = config_rng_defaults(:hwrng, options["os"])
        random_org_opts = config_rng_defaults(:random_org, options["os"])
    end
    rng_opts["hwrng"] = hwrng_opts
    rng_opts["random.org"] = random_org_opts

    src_heading = "MEDIA SOURCES CONFIGURATION:"
    puts "\n" + src_heading
    (1..src_heading.length).each { |x| print "-" }
    puts

    options["sources"] = src_opts = Hash.new
    src_opts["path"] = ask("Please specify where is your file containing media sources located: ") do |q|
        q.default = "sources.yml"
    end
    src_opts["categories"] = ask("Please specify any category restrictions to apply when selecting source from " + src_opts["path"] + " (separate categories by space, subcategories by dots; categories starting with dot will be excluded, instead of included): ") do |q|
        q.validate = /^\.?[^. ]+(\.[^. ]+)*( \.?[^. ]+(\.[^. ]+)*)*$/
        q.default = "all"
    end

    src_opts["download"] = download_opts = Hash.new
    case options["os"]
    when "rpi"
        puts "WARNING: It is advised to use external storage with your Raspberry Pi. Doing otherwise could shorten your SD card's life span."
        download_opts["device"] = ask("Which device do you want to use (leave empty if your device isn't a HDD or if you don't want to spin your HDD down automatically after use by hdparm -y)? ") do |q|
            q.default = "/dev/sda"
        end
        download_opts["partition"] = ask("Which partition do you want to use (leave empty if you don't want Budík.rb to mount and unmount your device using udisks2)? ") do |q|
            q.default = "/dev/sda1"
        end
        download_opts["sleep"] = download_opts["device"] == "" ? false : true
        download_opts["mount"] = download_opts["partition"] == "" ? false : true
        download_opts["dir"] = ask("Please specify directory where to store your remote media sources: ") do |q|
            q.default = "/mnt/Budík.rb/"
        end
        download_opts["method"] = ask("Please specify whether you want to store downloaded remote sources, or remove them (store, remove): ") do |q|
            q.validate = /^store|remove$/
            q.default = "remove"
        end
    when "windows"
        download_opts["device"] = ""
        download_opts["partition"] = ""
        download_opts["sleep"] = false
        download_opts["mount"] = false
        download_opts["dir"] = ask("Please specify directory where to store your remote media sources: ") do |q|
            q.default = "downloads/"
        end
        download_opts["method"] = ask("Please specify whether you want to store downloaded remote sources, or remove them (store, remove): ") do |q|
            q.validate = /^store|remove$/
            q.default = "remove"
        end
    when "unix"
        case agree("Do you want to use an external device (y/n)? ")
        when true
            download_opts["device"] = ask("Which device do you want to use (leave empty if your device isn't a HDD or if you don't want to spin your HDD down automatically after use by hdparm -y)? ") do |q|
                q.default = "/dev/sda"
            end
            download_opts["partition"] = ask("Which partition do you want to use (leave empty if you don't want Budík.rb to mount and unmount your device using udisks2)? ") do |q|
                q.default = "/dev/sda1"
            end
            download_opts["sleep"] = download_opts["device"] == "" ? false : true
            download_opts["mount"] = download_opts["partition"] == "" ? false : true
            download_opts["dir"] = ask("Please specify directory where to store your remote media sources: ") do |q|
                q.default = "/mnt/Budík.rb/"
            end
        else
            download_opts["device"] = ""
            download_opts["partition"] = ""
            download_opts["sleep"] = false
            download_opts["mount"] = false
            download_opts["dir"] = ask("Please specify directory where to store your remote media sources: ") do |q|
                q.default = "downloads/"
            end
        end
        download_opts["method"] = ask("Please specify whether you want to store downloaded remote sources, or remove them (store, remove): ") do |q|
            q.validate = /^store|remove$/
            q.default = "remove"
        end
    end

    options["tv"] = tv_opts = Hash.new
    if options["os"] == "rpi"
        tv_heading = "TV CONFIGURATION:"
        puts "\n" + tv_heading
        (1..tv_heading.length).each { |x| print "-" }
        puts

        tv_opts["available"] = agree("Is TV connected to your Raspberry Pi using HDMI? Do you want to use it (y/n)? ")
        if tv_opts["available"]
            tv_opts["use_if_no_video"] = agree("Do you want to use your TV for sources with no video (y/n)? ")
            tv_opts["wait_secs_after_on"] = ask("How many seconds should program wait to give your TV time to turn on (0-120)? |15| ") do |q|
                q.in = 0..120
                q.default = 15
            end
        end
    else
        tv_opts["available"] = false
        tv_opts["use_if_no_video"] = false
        tv_opts["wait_secs_after_on"] = 0
    end

    result_heading = "HERE IS YOUR NEW CONFIGURATION:"
    puts
    (1..tv_heading.length).each { |x| print "=" }
    puts "\n" + result_heading
    (1..tv_heading.length).each { |x| print "=" }
    puts

    options_yml = options.ya2yaml(syck_compatible: true)
    puts options_yml
    File.open(filename, "w") { |f| f.puts options_yml }

    # TODO: Set as default?
end

def config_use_template
    templates = Dir["options/templates/*.yml"]
    puts "You have these templates available:" unless templates.empty?

    n = 0
    templates.each do |template|
        puts "[#{n}]: #{template}"
        n += 1
    end

    choice = ask("Which one do you want to use (use -1 to cancel)? ", Integer) { |q| q.in = -1..(templates.length - 1) }
    choice == -1 ? nil : templates[choice]
end

def config_player_defaults(player)
    player_opts = Hash.new
    case player
    when :omxplayer
        player_opts["default_volume"] = -2100
        player_opts["path"] = "omxplayer"
        player_opts["volume_step_secs"] = 3
    when :vlc
        player_opts["default_volume"] = 128
        player_opts["fullscreen"] = true
        player_opts["path"] = "vlc"
        player_opts["rc_host"] = "localhost"
        player_opts["rc_port"] = 50000
        player_opts["volume_fade_in_secs"] = 0.125
        player_opts["volume_step"] = 1.0
        player_opts["wait_secs_after_vlc_runs"] = 5
        player_opts["wait_secs_if_http_source"] = 3
    end
    player_opts
end

def config_rng_defaults(method, os)
    rng_opts = Hash.new
    case method
    when :hwrng
        rng_opts["source"] = os == "windows" ? "" : (os == "rpi" ? "/dev/hwrng" : "/dev/random")
    when :random_org
        rng_opts["apikey"] = ""
    end
    rng_opts
end

def config_edit(name)
end

def config_set(name)
end

def config_delete(name)
    # TODO: Check if sure
end
