require 'net/http'
require 'uri'
require 'json'

class BitcoreRPC
  class Unauthenticated < StandardError; end;
  class ConnectionError < StandardError; end;
  class ResponseError < StandardError
    def initialize(code, msg)
      super "#{msg} (#{code})"
    end
  end

  attr_accessor :user, :password, :host, :port, :network, :debug

  def initialize(args={})
    self.user = args.fetch(:user)
    self.password = args.fetch(:password)
    self.network = args.fetch(:network, :testnet)
    raise ::ArgumentError.new("unknown network:#{network}") unless [:livenet, :testnet].map(&:to_s).include?(network.to_s)
    self.host = args.fetch(:host, "localhost")
    self.port = args.fetch(:port, "18332")
    self.debug = args.fetch(:debug, Rails.env.development? )
  end

  def method_missing(name, *args)
    request(name, args)
  end

  def get_transactions(label="*", amount=100, skip=0, watchonly=false)
    request(:listtransactions, label, amount, skip, watchonly)
  end

  private

  def base_uri
    "http://#{host}:#{port}/"
  end

  def request(method, *args)
    uri = URI.parse(base_uri)
    header = {'Content-Type': 'text/json'}
    params = {
      jsonrpc: 1.0,
      method: method,
      params: [args].flatten.compact
    }

    p "sending request to #{uri}, method: #{method}, args: #{args.flatten}" if debug

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth(user, password)
    request.body = params.to_json
    begin
      response = http.request(request)
    rescue Errno::ECONNREFUSED => e
      raise ConnectionError.new(e)
    end

    raise Unauthenticated if response.code == "401" || response.code == "403"

    json = JSON.parse(response.body)
    if error = json["error"]
      raise ResponseError.new(error['code'], error['message'])
    end
    json["result"]
  end
end
