require 'spec_helper'

describe Budik::Rng, '#generate' do
  rng = Budik::Rng.new
  options = Budik::Config.instance.options['rng']

  context 'using hwrng' do
    it 'generates random number' do
      options['method'] = 'hwrng'

      options['hwrng']['source'] = '/dev/hwrng'
      5.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end

      options['hwrng']['source'] = '/dev/random'
      5.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end

      options['hwrng']['source'] = '/dev/urandom'
      100.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end

  context 'using random.org' do
    it 'generates random number' do
      options['method'] = 'random.org'
      if options['random.org']['apikey']
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end

  context 'using srand' do
    it 'generates random number' do
      options['method'] = 'rand'
      100.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end
end
