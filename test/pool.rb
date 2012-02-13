require 'cutest'
require 'mock_server'
require_relative '../lib/net/http/pool'

extend MockServer::Methods

mock_server {
  get '/' do
    'What is up dog!'
  end

  get '/marco' do
    'polo'
  end

  post '/post' do
    'the post'
  end

  put '/put' do
    'the put'
  end
}

test "establishes a persistent connection" do
  pool = Net::HTTP::Pool.new("http://localhost:4000/", debug: true)
  res = pool.get("/")

  assert_equal "200", res.code
  assert_equal 'What is up dog!', res.body

  res = pool.get("/marco")

  assert_equal "200", res.code
  assert_equal 'polo', res.body

  res = pool.post("/post", 'test', {'X-Fancy-Header' => 'Sometimes'})

  assert_equal "200", res.code
  assert_equal 'the post', res.body

  res = pool.put("/put")

  assert_equal "200", res.code
  assert_equal 'the put', res.body
end
