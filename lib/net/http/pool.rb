require 'celluloid'
require 'net/http/persistent'

class Net::HTTP::Pool
  include Celluloid

  class MissingBlock < StandardError; end

  class Connections
    include Celluloid

    attr_reader :pool

    def initialize(host, options = {})
      @current_index = 0
      @pool = Array.new(options.fetch(:size, 5)) do
        connection = Net::HTTP::Persistent.new(host)
        connection.idle_timeout = nil
        connection
      end
    end

    def round_robin(&block)
      @current_index = @current_index > @pool.size ? 0 : @current_index + 1
      yield @pool[@current_index] if block
    end

    def with(&block)
      round_robin! &block
    end
  end

  def initialize(host)
    @pool = Connections.new(host)
    @uri = URI host
  end

  def get(path, headers = {}, &block)
    request!(path, Net::HTTP::Get, nil, headers, &block)
  end

  def post(path, body = nil, headers, &block)
    request!(path, Net::HTTP::Post, body, headers, &block)
  end

  def put(path, body = nil, headers, &block)
    request!(path, Net::HTTP::Put, body, headers, &block)
  end

  def request(path, type, body = nil, headers = {}, &block)
    raise MissingBlock, "You must pass a block" unless block
    @pool.with do |connection|
      request = type.new(path)
      request.body = body if body
      headers.each { |key, value| request.add_field(key, value) }
      request['Content-Length'] = body && body.length || 0
      yield connection.request(@uri, request) if block
    end
  end
end
