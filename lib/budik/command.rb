module Budik
  # 'Command' class holds definitions of CLI commands.
  class Command
    def initialize(command, opts)
      @options = Config.instance.options
      @sources = Config.instance.sources
      @strings = Config.instance.lang.command

      send(command, opts)
    end

    private

    def config(opts)
      if opts.reset
        Config.instance.reset
      else
        Config.instance.edit
      end
    end

    def run(opts)
      run_alarm(opts)
    rescue
      run_alarm_fallback
    end

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

    def run_alarm_fallback
      50.times do
        puts "\a"
        sleep 1.2
      end
    end

    def run_use_cli_opts(opts)
      @options['player']['player'] = opts.player if opts.player
      @options['rng']['method'] = opts.rng if opts.rng
      return unless opts.dl_method
      @options['sources']['download']['method'] = opts.dl_method
    end

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

    def run_download(source, dl_method, storage)
      dl_method == 'stream' ? source : storage.download_sources(source)
    end

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

    def sources_list_dl(sources, opts)
      mods = opts.categories ? sources.parse_mods(opts.categories) : nil
      sources.apply_mods(mods) if mods

      if opts.download
        Storage.instance.download_sources
      else
        IO.instance.sources_print(sources.sources)
      end
    end

    def translate(args)
      Config.instance.translate(args.first)
    end
  end
end
