require 'singleton'
require 'spec_helper'

require 'budik/rng'

describe Budik::Rng, '#generate' do
  context 'using hwrng' do
    it 'generates random number' do
      config = Budik::Config.instance

      config.options['rng']['hwrng']['source'] = '/dev/hwrng'
      5.times do
        num = Budik::Rng.instance.generate(100, 'hwrng')
        expect(num >= 0 && num < 100).to eq true
      end

      config.options['rng']['hwrng']['source'] = '/dev/random'
      5.times do
        num = Budik::Rng.instance.generate(100, 'hwrng')
        expect(num >= 0 && num < 100).to eq true
      end

      config.options['rng']['hwrng']['source'] = '/dev/urandom'
      100.times do
        num = Budik::Rng.instance.generate(100, 'hwrng')
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end

  context 'using random.org' do
    it 'generates random number' do
      config = Budik::Config.instance

      if config.options['rng']['random.org']['apikey']
        num = Budik::Rng.instance.generate(100, 'random.org')
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end

  context 'using srand' do
    it 'generates random number' do
      100.times do
        num = Budik::Rng.instance.generate(100, 'rand')
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end
end
