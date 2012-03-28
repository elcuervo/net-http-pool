require 'cutest'
require_relative '../lib/net/http/pool'

scope do
  test "generates the default pool" do
    connections = Net::HTTP::Pool::Connections.new('http://localhost', size: 9)
    assert connections.pool.size == 9
  end
end
