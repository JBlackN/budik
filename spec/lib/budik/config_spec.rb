require 'r18n-core'
require 'singleton'
require 'spec_helper'
require 'yaml'

require 'budik/config'

describe Budik::Config, '#load' do
  context 'with default values' do
    it 'loads configuration files' do
      opts = {}
      config = Budik::Config.instance
      config.load(opts)

      expect(config.lang.lang.class).to eq R18n::TranslatedString
      expect(config.options).to eq YAML.load_file('./lib/budik/config/options.yml')
      expect(config.sources).to eq YAML.load_file('./lib/budik/config/sources.yml')
     end
  end

  context 'with file overrides' do
    it 'loads configuration files' do
      opts = { language: 'en',
               options: './lib/budik/config/options.yml',
               sources: './lib/budik/config/sources.yml' }
      config = Budik::Config.instance
      config.load(opts)

      expect(config.lang.lang.class).to eq R18n::TranslatedString
      expect(config.options).to eq YAML.load_file('./lib/budik/config/options.yml')
      expect(config.sources).to eq YAML.load_file('./lib/budik/config/sources.yml')
    end
  end
end
