require 'spec_helper'

describe Budik::Config, '#initialize' do
  context 'with default values' do
    it 'loads configuration files' do
      config = Budik::Config.instance
      options = './lib/budik/config/options.yml'
      sources = config.options['sources']['path']

      expect(config.lang.lang.class).to eq R18n::TranslatedString
      expect(config.options).to eq YAML.load_file(options)
      expect(config.sources).to eq YAML.load_file(sources)
    end
  end
end
