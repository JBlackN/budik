module Budik
  def command_config(_args, opts)
    _config = Config.instance.load(opts)
  end

  def command_run(_args, opts)
    config.load(opts)
  end

  def command_set(_args, opts)
  end

  def command_sources(_args, opts)
  end

  def command_translate(_args, opts)
  end

  def command_unset(_args, opts)
  end
end
