require 'cutest'
require_relative '../lib/net/http/pool'

test "establishes a persistent connection" do
  pool = Net::HTTP::Pool.new("http://localhost:4567/", debug: true)
  res = pool.get("/")
  assert_equal 'What is up dog!', res.body

  res = pool.get("/marco")
  assert_equal 'polo', res.body
end
