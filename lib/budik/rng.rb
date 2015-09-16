module Budik
  # 'Rng' class provides various methods for random number generation.
  class Rng
    def initialize
      @options = Config.instance.options['rng']
      @method = @options['method']
    end

    attr_accessor :options, :method

    def generate(items)
      case @method
      when 'hwrng'
        hwrng(@options['hwrng'], items)
      when 'random.org'
        random_org(@options['random.org'], items)
      when 'rand-hwrng-seed'
        swrng(items, hwrng(@options['hwrng'], 2**64))
      else
        swrng(items)
      end
    end

    private

    def hwrng(options, items)
      source = File.new(options['source'], 'r')
      max = 2**64
      bound = items - 1
      threshold = (max - bound) % bound
      number = source.read(8).unpack('Q') while number.first < threshold
      number.first % bound
    rescue
      swrng(items)
    end

    def random_org(options, items)
      response = random_org_request(options, items)

      if response.code.to_i == 200
        JSON.parse(response.body)['result']['random']['data'].first
      else
        swrng(items)
      end
    end

    def random_org_request_data(apikey, items)
      { jsonrpc: '2.0',
        method: 'generateIntegers',
        params: {
          apiKey: apikey,
          n: 1,
          min: 0,
          max: items - 1
        },
        id: 29 }
    end

    def random_org_request(options, items)
      uri = URI.parse('http://api.random.org/json-rpc/1/invoke')
      header = { 'Content-Type' => 'application/json-rpc' }
      data = random_org_request_data(options['apikey'], items)

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = data.to_json

      random_org_request_send(http, request)
    end

    def random_org_request_send(http, request)
      http.request(request)
    rescue
      swrng(items)
    end

    def swrng(items, seed = nil)
      seed.nil? ? srand : srand(seed) # TODO: Test this
      rand(0...items)
    end
  end
end
