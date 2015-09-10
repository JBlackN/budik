module Budik
  class Command
    include Singleton

    def initialize
      @options = nil
      @sources = nil
    end

    def load_config(sources, overrides)
      Options.instance.load_config(overrides.options, overrides.language) # TODO: Exception handling
      @options = Options.instance.options

      if sources
        sources = overrides.sources ? overrides.sources : @options['sources']['path']
        Sources.instance.load_sources(sources)
        @sources = Sources.instance.sources
      end
    end

    # COMMANDS

    def config(_args, opts)
    end

    def run(_args, opts)
    end

    def set(_args, opts)
    end

    def sources(_args, opts)
    end

    def translate(_args, opts)
    end

    def uninstall(_args, opts)
    end

    def unset(_args, opts)
    end

    def update(_args, opts)
    end
  end
end
