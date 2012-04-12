require 'celluloid'
require 'net/http/persistent'

# Public: The Pool itself
#
# host - The string of the host.
class Net::HTTP::Pool
  include Celluloid

  # Private: Custom Error for a missing block in the call.
  class MissingBlock < StandardError
    def message
      "You must pass a block"
    end
  end

  # Public: The Connection Pool.
  #
  # host    - The string of the host.
  # options - The hash of options (default: {}).
  #           :size - The integer size of the pool (default: 5)
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

    # Private: Round robin one of the connections
    #
    # &block - The block to be called passing the current connection
    def round_robin(&block)
      raise MissingBlock unless block
      @current_index = @current_index > @pool.size ? 0 : @current_index + 1
      yield @pool[@current_index] if block
    end

    # Public: Helper to access the connection asynchronous
    #
    # &block - The block to be called passing the current connection
    def with(&block)
      round_robin! &block
    end
  end

  def initialize(host, options = {})
    @pool = Connections.new(host, options)
    @uri = URI(host)
  end

  def get(path, headers = {}, &block)
    request!(path, Net::HTTP::Get, nil, headers, &block)
  end

  def post(path, body = nil, headers = {}, &block)
    request!(path, Net::HTTP::Post, body, headers, &block)
  end

  def put(path, body = nil, headers = {}, &block)
    request!(path, Net::HTTP::Put, body, headers, &block)
  end

  def delete(path, headers = {}, &block)
    request!(path, Net::HTTP::Delete, headers, &block)
  end

  def request(path, type, body = nil, headers = {}, &block)
    raise MissingBlock unless block
    @pool.with do |connection|
      request = type.new(path)
      request.body = body if body
      headers.each { |key, value| request.add_field(key, value) }
      request['Content-Length'] = body && body.length || 0
      yield connection.request(@uri, request) if block
    end
  end
end
