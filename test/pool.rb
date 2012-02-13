require 'cutest'
require_relative '../lib/net/http/pool'

test "establishes a persistent connection" do
  pool = Net::HTTP::Pool.new("http://localhost:4567/", debug: true)
  res = pool.get("/")
  assert_equal 'What is up dog!', res.body

  res = pool.get("/marco")
  assert_equal 'polo', res.body

  res = pool.post("/post", 'test', {'X-Fancy-Header' => 'Sometimes'})
  assert_equal 'the post', res.body

  res = pool.put("/put")
  assert_equal 'the put', res.body
end
