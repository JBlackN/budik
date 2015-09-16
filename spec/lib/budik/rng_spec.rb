require 'spec_helper'

rng = Budik::Rng.new
options = Budik::Config.instance.options['rng']

describe Budik::Rng, '#generate' do
  context 'using hwrng' do
    it 'generates random number' do
      options['method'] = rng.method = 'hwrng'

      options['hwrng']['source'] = '/dev/hwrng'
      rng.options = options
      5.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end

      options['hwrng']['source'] = '/dev/random'
      rng.options = options
      5.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end

      options['hwrng']['source'] = '/dev/urandom'
      rng.options = options
      100.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end

  context 'using random.org' do
    it 'generates random number' do
      options['method'] = rng.method = 'random.org'
      if !options['random.org']['apikey'].empty?
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      else
        srand
        100.times do
          response = instance_double('Net::HTTPResponse')
          response_code = 200
          response_body = '{
            "jsonrpc": "2.0",
            "result": {
              "random": {
                "data": [$number],
                "completionTime": "2011-10-10 13:19:12Z"
              },
              "bitsUsed": 16,
              "bitsLeft": 199984,
              "requestsLeft": 9999,
              "advisoryDelay": 0
            },
            "id": 42
          }'
          response_body.gsub!(/\$number/, rand(0...100).to_s)
          allow(response).to receive(:code) { response_code }
          allow(response).to receive(:body) { response_body }

          allow(rng).to receive(:random_org_request) { response }
          expect(rng).not_to receive(:swrng)
          number = rng.generate(100)
          expect(number >= 0 && number < 100).to be true
        end
      end
    end
  end

  context 'using srand' do
    it 'generates random number' do
      options['method'] = rng.method = 'rand'
      100.times do
        num = rng.generate(100)
        expect(num >= 0 && num < 100).to eq true
      end
    end
  end
end
