module Budik
  def self.command_config(_args, opts)
    _config = Config.instance.load(opts)
  end

  def self.command_run(_args, opts)
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

  def self.command_set(_args, opts)
  end

  def self.command_sources(_args, opts)
  end

  def self.command_translate(_args, opts)
  end

  def self.command_unset(_args, opts)
  end
end
