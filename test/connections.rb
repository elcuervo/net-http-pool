require 'cutest'
require_relative '../lib/net/http/pool'

scope do
  test "generates the default pool" do
    connections = Net::HTTP::Pool::Connections.new('http://localhost')
    assert connections.pool.size == 5
  end
end
