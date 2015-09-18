require 'spec_helper'

config = Budik::Config.instance
options = Dir.home + '/.budik/options.yml'

describe Budik::Config, '#initialize' do
  context 'with default values' do
    it 'loads configuration files' do
      sources = File.expand_path(config.options['sources']['path'])

      expect(config.lang.lang.class).to eq R18n::TranslatedString
      expect(config.options).to eq YAML.load_file(options)
      expect(config.sources).to eq YAML.load_file(sources)
    end
  end
end

describe Budik::Config, '#edit' do
  context 'under Windows' do
    it 'opens configuration file using default editor via Powershell' do
      config.options['os'] = 'windows'
      command = '@powershell -Command "' + options + '"'
      expect(config).to receive(:system).with(command)
      config.edit
    end
  end

  context 'under *nix' do
    it 'uses $EDITOR environment variable to open configuration file' do
      config.options['os'] = 'linux'
      ENV['EDITOR'] = '/usr/bin/nano'
      command = '/usr/bin/nano "' + options + '"'

      expect(config).to receive(:system).with(command)
      config.edit
    end

    it 'opens configuration file using vi when $EDITOR is not set' do
      config.options['os'] = 'linux'
      ENV['EDITOR'] = nil
      command = 'vi "' + options + '"'

      expect(config).to receive(:system).with(command)
      config.edit
    end
  end
end

describe Budik::Config, '#platform?' do
  it 'returns :windows, :linux or :rpi' do
    expect(config.platform?).to eq(:windows).or eq(:linux).or eq(:rpi)
  end
end

describe Budik::Config, '#reset' do
  it 'resets configuration file' do
    opts_bk = Dir.home + '/.budik/options.yml.bk'
    FileUtils.cp(options, opts_bk)
    expect(FileUtils.cmp(options, opts_bk)).to be true

    File.open(options, 'w') { |file| file.write('test') }
    expect(IO.read(options)).to eq 'test'

    platform = config.platform?
    opts_new = './config/templates/options/' + platform.to_s + '.yml'
    config.reset
    expect(FileUtils.cmp(opts_new, options)).to be true

    FileUtils.cp(opts_bk, options)
    expect(FileUtils.cmp(options, opts_bk)).to be true
    FileUtils.rm(opts_bk, force: true)
    expect(File.file? opts_bk).to be false
  end
end
