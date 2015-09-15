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

    def config(_opts)
    end

    def run(opts)
      sources = Sources.instance
      devices = Devices.instance
      rng = Rng.new
      output = Output.instance
      player = Player.instance

      run_use_cli_opts(opts)
      source = run_prepare(opts, sources, devices, rng, output)
      run_play(source, devices, player, sources)
    end

    def run_use_cli_opts(opts)
      @options['sources']['download']['keep'] = opts.dl_keep if opts.dl_keep
      @options['player']['player'] = opts.player if opts.player
      @options['rng']['method'] = opts.rng if opts.rng
    end

    def run_prepare(opts, sources, devices, rng, output)
      sources.parse(@sources)
      mods = opts.categories ? sources.parse_mods(opts.categories) : nil
      sources.apply_mods(mods) if mods

      devices.storage_mount
      number = opts.number || rng.generate(sources.count)
      source = sources.get(number)

      puts output.run_info_table(number, source[:name])
      sources.download(source)
    end

    def run_play(source, devices, player, sources)
      devices.tv_on
      player.play(source)

      devices.tv_off
      sources.remove(source)
      devices.storage_unmount
      devices.storage_sleep
    end

    def sources(_opts)
    end

    def translate(_opts)
    end
  end
end
