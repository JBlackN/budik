require 'net/http'
require 'json'

def rng(options, items, method_override = nil)
    unless method_override != nil
        method = options["method"]
    else
        method = method_override
    end

    case method
    when "hwrng"
        hwrng(options["hwrng"], items)
    when "random.org"
        random_org(options["random.org"], items)
    when "rand-hwrng-seed"
        swrng(items, hwrng(options["hwrng"], 2**64))
    when "rand"
        swrng(items)
    else
        puts "Invalid RNG method specified. Using rand() with default seed."
    end
end

def hwrng(options, items)
    begin
        source = File.new(options["source"], "r")
        max = 2**64
        threshold = (max - items) % items
        number = source.read(8).unpack("Q")
        while number.first < threshold do
            number = source.read(8).unpack("Q")
        end
        number.first % items
    rescue
        puts "Error: Couldn't obtain random number from #{options["source"]}."
        puts "Falling back to rand() with default seed."
        swrng(items)
    end
end

def random_org(options, items)
    uri = URI.parse("http://api.random.org/json-rpc/1/invoke")
    header = { 'Content-Type' => 'application/json-rpc' }
    data = {
        jsonrpc: "2.0",
        method: "generateIntegers",
        params: {
            apiKey: options["apikey"],
            n: 1,
            min: 0,
            max: items
        },
        id: 29
    }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data.to_json

    begin
        response = http.request(request)
    rescue
        puts "Error: Couldn't obtain random number from Random.org."
        puts "Falling back to rand() with default seed."
        swrng(items)
    end

    if response.code.to_i == 200
        JSON.parse(response.body)["result"]["random"]["data"].first
    else
        puts "Error: Couldn't obtain random number from Random.org."
        puts "Response code: #{response.code}."
        puts "Response body: #{response.body}."
        puts "Falling back to rand() with default seed."
        swrng(items)
    end
end

def swrng(items, seed = nil)
    seed == nil ? srand() : srand(seed) # TODO: Test this
    rand(0...items)
end
