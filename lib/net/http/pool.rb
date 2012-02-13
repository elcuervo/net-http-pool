require 'connection_pool'
require 'net/http/persistent'

class Net::HTTP::Pool
  attr_reader :url

  def initialize(url, options = {})
    @url = URI(url)
    @pool = ConnectionPool.new(size: 5) do
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

  private

  def with_connection(&block)
    @connection = if !!@connection && @connection.active?
                    @connection
                  else
                    @pool.with { |net| net.connection_for(@url) }
                  end

    yield(@connection) if block_given?
  end

  def request(path, type, body = nil, headers = {})
    with_connection do |connection|
      connection.request type.new(path, headers), body
    end
  end

end
