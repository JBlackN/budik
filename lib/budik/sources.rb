module Budik
  class Sources
    include Singleton

    def initialize
      @sources = nil
    end

    def load_sources(path)
      @sources = YAML.load_file(path)
      @sources.each do |source|
        normalize_source(source)
      end
    end

    def normalize_source(source)
      # TODO
    end
  end
end
