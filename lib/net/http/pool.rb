require 'celluloid'
require 'net/http/persistent'

# Public: The Pool itself
#
# host - The string of the host.
class Net::HTTP::Pool
  include Celluloid

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
      raise LocalJumpError unless block

      @current_index = @current_index > @pool.size ? 0 : @current_index + 1
      yield @pool[@current_index]
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

  def request(request, &block)
    async_request!(request, &block)
  end

  def async_request(request, &block)
    raise LocalJumpError unless block

    @pool.with do |connection|
      yield connection.request(@uri, request)
    end
  end

end
