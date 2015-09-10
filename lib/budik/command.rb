module Budik
  def self.command_config(_args, opts)
    _config = Config.instance.load(opts)
  end

  def self.command_run(_args, opts)
    config.load(opts)
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
