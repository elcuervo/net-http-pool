require 'connection_pool'
require 'net/http/persistent'

class Net::HTTP::Pool
  attr_reader :url

  def initialize(url, options = {})
    @url = URI(url)
    @pool = ConnectionPool.new(options) do
      persistent = Net::HTTP::Persistent.new(options.fetch(:name, nil))
      if options.fetch(:debug, false)
        persistent.debug_output = options.fetch(:logger, $stderr)
        persistent.debug_output.write "New persistent connection to: %s\n" % url
      end
      persistent
    end
  end

  def get(path, headers = {})
    request(path, Net::HTTP::Get, nil, headers)
  end

  def post(path, body = nil, headers = {})
    request(path, Net::HTTP::Post, body, headers)
  end

  def put(path, body = nil, headers = {})
    request(path, Net::HTTP::Put, body, headers)
  end

  def delete(path, body = nil, headers = {})
    request(path, Net::HTTP::Delete, body, headers)
  end

  def options(path, body = nil, headers = {})
    request(path, Net::HTTP::Options, body, headers)
  end

  private

  def request(path, type = Net::HTTP::Get, body = nil, headers = {})
    req = type.new(path)
    req.body = body if body
    req['Content-Length'] = body && body.length || 0
    headers.each { |key, value| req.add_field key, value }

    @pool.with { |persistent| persistent.request @url, req }
  end

end
