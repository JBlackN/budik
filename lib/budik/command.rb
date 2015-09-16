module Budik
  # 'Command' class holds definitions of CLI commands.
  class Command
    def initialize(command, opts)
      @options = Config.instance.options
      @dl_method = @options['sources']['download']['method']
      @sources = Config.instance.sources
      @strings = Config.instance.lang.command

      send(command, opts)
    end

    private

    def config(_opts)
    end

    def run(opts)
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
      dl_method == 'stream' ? source : storage.download(source)
    end

    def run_play(source, devices, player, storage)
      devices.tv_on
      player.play(source)

      devices.tv_off
      storage.remove_sources(source)
      devices.storage_unmount
      devices.storage_sleep
    end

    def sources(_opts)
    end

    def translate(_opts)
    end
  end
end
