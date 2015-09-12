module Budik
  class Command
    include Singleton

    def config(_args, opts)
    end

    def run(_args, opts)
      options = Config.instance.options
      dl_options = options['sources']['download']

      dl_options['keep'] = opts.download_keep if opts.download_keep
      options['player']['player'] = opts.player if opts.player
      options['rng']['method'] = opts.rng if opts.rng

      sources = Sources.instance
      rng = Rng.instance
      devices = Devices.instance
      player = Player.instance

      sources.parse(options['sources']['path'], opts.categories)
      devices.storage_mount
      number = opts.number ? opts.number : rng.generate(sources.count)
      sources.download(number)

      devices.tv_on
      player.play(sources.sources[number])
      devices.tv_off
      sources.remove(number)
      devices.storage_unmount
      devices.storage_sleep
    end

    def set(_args, opts)
    end

    def sources(_args, opts)
    end

    def translate(_args, opts)
    end

    def unset(_args, opts)
    end
  end
end
