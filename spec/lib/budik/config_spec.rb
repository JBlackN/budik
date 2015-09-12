require 'r18n-core'
require 'singleton'
require 'spec_helper'
require 'yaml'

require 'budik/config'

describe Budik::Config, '#initialize' do
  context 'with default values' do
    it 'loads configuration files' do
      config = Budik::Config.instance

      expect(config.lang.lang.class).to eq R18n::TranslatedString
      expect(config.options).to eq YAML.load_file('./lib/budik/config/options.yml')
      expect(config.sources).to eq YAML.load_file(config.options['sources']['path'])
     end
  end
end
