# = rng.rb
# This file contains methods for random number generation.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 20, 2015

module Budik
  # 'Rng' class provides various methods for random number generation.
  class Rng
    # Loads RNG options including method.
    def initialize
      @options = Config.instance.options['rng']
      @method = @options['method']
    end

    # Gets RNG options and method.
    attr_accessor :options, :method

    # Generates random number.
    #
    # - *Args*:
    #   - +items+ -> Total number of items (Fixnum).
    # - *Returns*:
    #   - Fixnum (0...items)
    #
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

    # Reads random number from hwrng (/dev/hwrng, /dev/(u)random).
    # Removes modulo bias.
    # http://funloop.org/post/2015-02-27-removing-modulo-bias-redux.html
    # Falls back to swrng if an exception is encountered.
    #
    # - *Args*:
    #   - +options+ -> Hwrng options (Hash).
    #   - +items+ -> Total number of items (Fixnum).
    # - *Returns*:
    #   - Fixnum (0...items)
    #
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

    # Queries Random.org API to obtain random number.
    # https://api.random.org/json-rpc/1/
    # Falls back to swrng if incorrect response is received.
    #
    # - *Args*:
    #   - +options+ -> Random.org options (Hash).
    #   - +items+ -> Total number of items (Fixnum).
    # - *Returns*:
    #   - Fixnum (0...items)
    #
    def random_org(options, items)
      response = random_org_request(options, items)
      return response if response.is_a? Fixnum

      if response.code.to_i == 200
        JSON.parse(response.body)['result']['random']['data'].first
      else
        swrng(items)
      end
    end

    # Generates Random.org API request data.
    #
    # - *Args*:
    #   - +apikey+ -> Random.org API key (String).
    #   - +items+ -> Total number of items (Fixnum).
    # - *Returns*:
    #   - Random.org API request data (Hash).
    #
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

    # Builds a request and sends it to Random.org API.
    #
    # - *Args*:
    #   - +options+ -> Random.org options (Hash).
    #   - +items+ -> Total number of items (Fixnum).
    # - *Returns*:
    #   - Random.org API response object or Fixnum (0...items).
    #
    def random_org_request(options, items)
      uri = URI.parse('http://api.random.org/json-rpc/1/invoke')
      header = { 'Content-Type' => 'application/json-rpc' }
      data = random_org_request_data(options['apikey'], items)

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = data.to_json

      random_org_request_send(http, request)
    end

    # Sends a request to Random.org API.
    #
    # - *Args*:
    #   - +http+ -> Net::HTTP object.
    #   - +request+ -> Net::HTTP::Post object.
    # - *Returns*:
    #   - HTTPResponse object or Fixnum (0...items).
    #
    def random_org_request_send(http, request)
      http.request(request)
    rescue
      swrng(items)
    end

    # Generates random number using (s)rand.
    #
    # - *Args*:
    #   - +items+ -> Total number of items (Fixnum).
    #   - +seed+ -> Custom seed for rand.
    # - *Returns*:
    #   - Fixnum (0...items).
    #
    def swrng(items, seed = nil)
      seed.nil? ? srand : srand(seed) # TODO: Test this
      rand(0...items)
    end
  end
end
