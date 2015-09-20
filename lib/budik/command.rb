# = command.rb
# This file contains definitions of the application's commands.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 19, 2015

module Budik
  # 'Command' class holds definitions of CLI commands.
  class Command
    # Loads options, sources and strings.
    # Runs command and passes specified options to it.
    #
    # - *Args*:
    #   - +command+ -> Command to run (Symbol)
    #   - +opts+ -> Command line options (Ruby Commander's object)
    #
    def initialize(command, opts)
      @options = Config.instance.options
      @sources = Config.instance.sources
      @strings = Config.instance.lang.command

      send(command, opts)
    end

    private

    # Defines command 'config'.
    # Opens configuration file for editing or resets it.
    #
    # - *Args*:
    #   - +opts+ -> Command line options
    #
    def config(opts)
      if opts.reset
        Config.instance.reset
      else
        Config.instance.edit
      end
    end

    # Runs alarm or falls back if an error is encountered.
    #
    # - *Args*:
    #   - +opts+ -> Command line options
    #
    def run(opts)
      run_alarm(opts)
    rescue
      run_alarm_fallback
    end

    # Defines command 'run'.
    # Runs alarm.
    #
    # - *Args*:
    #   - +opts+ -> Command line options
    #
    def run_alarm(opts)
      sources = Sources.instance
      storage = Storage.instance
      devices = Devices.instance
      rng = Rng.new
      io = IO.instance
      player = Player.instance

      run_use_cli_opts(opts)
      source = run_prepare(opts, sources, devices, rng, io)
      run_download(source, storage.method, storage)
      run_play(source, devices, player, storage)
    end

    # Outputs bell code 50 times in 1.2s intervals.
    def run_alarm_fallback
      50.times do
        puts "\a"
        sleep 1.2
      end
    end

    # Applies command line options (player, rng, dl_method)
    #
    # - *Args*:
    #   - +opts+ -> Command line options
    #
    def run_use_cli_opts(opts)
      @options['player']['player'] = opts.player if opts.player
      @options['rng']['method'] = opts.rng if opts.rng
      return unless opts.dl_method
      @options['sources']['download']['method'] = opts.dl_method
    end

    # Parses sources, applies category modifiers, mounts device if needed,
    # generates random number and uses it to return source.
    #
    # - *Args*:
    #   - +opts+ -> Command line options
    #   - +sources+ -> Sources class instance
    #   - +devices+ -> Devices class instance
    #   - +rng+ -> Rng class instance
    #   - +io+ -> IO class instance
    # - *Returns*:
    #   - Source (Hash)
    #
    def run_prepare(opts, sources, devices, rng, io)
      sources.parse(@sources)
      mods = opts.categories ? sources.parse_mods(opts.categories) : nil
      sources.apply_mods(mods) if mods

      devices.storage_mount
      number = opts.number || rng.generate(sources.count)
      source = sources.get(number)

      puts io.run_info_table(number, source[:name])
      source
    end

    # Downloads source if needed.
    #
    # - *Args*:
    #   - +source+ -> Source (Hash)
    #   - +dl_method+ -> Download method (string: keep, remove or stream)
    #   - +storage+ -> Storage class instance
    #
    def run_download(source, dl_method, storage)
      storage.download_sources(source) unless dl_method == 'stream'
    end

    # Turns on tv if needed.
    # Plays source or falls back if player unexpectedly exits too soon.
    # If needed, turns off TV, removes source and unmounts storage.
    #
    # - *Args*:
    #   - +sources+ -> Sources class instance
    #   - +devices+ -> Devices class instance
    #   - +player+ -> Player class instance
    #   - +storage+ -> Storage class instance
    #
    def run_play(source, devices, player, storage)
      devices.tv_on

      start = Time.now
      player.play(source)
      run_alarm_fallback if Time.now - start < 5.0

      devices.tv_off
      storage.remove_sources(source)
      devices.storage_unmount
      devices.storage_sleep
    end

    # Defines command 'sources'
    # Opens sources file for editing or prepares sources
    # for viewing or downloading.
    #
    # - *Args*:
    #   - +opts+ -> Command line options
    #
    def sources(opts)
      if opts.edit
        path = File.expand_path(Config.instance.options['sources']['path'])
        Config.instance.open_file(path)
      else
        sources = Sources.instance
        sources.parse(@sources)
        sources_list_dl(sources, opts)
      end
    end

    # Applies category modifiers and lists or download sources.
    #
    # - *Args*:
    #   - +sources+ -> Sources class instance
    #   - +opts+ -> Command line options
    #
    def sources_list_dl(sources, opts)
      mods = opts.categories ? sources.parse_mods(opts.categories) : nil
      sources.apply_mods(mods) if mods

      if opts.download
        Storage.instance.download_sources
      else
        IO.instance.sources_print(sources.sources)
      end
    end

    # Creates and/or opens language file for translation.
    #
    # - *Args*:
    #   - +args+ -> Command line arguments, first used as language code
    #
    def translate(args)
      Config.instance.translate(args.first)
    end
  end
end
