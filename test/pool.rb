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
    params[:test] ? 'this is a test' : 'the post'
  end

  put '/put' do
    params[:run] || 'the put'
  end
}

test "establishes a persistent connection" do
  pool = Net::HTTP::Pool.new("http://localhost:4000/")
  res = pool.get("/")

  assert_equal "200", res.code
  assert_equal 'What is up dog!', res.body

  res = pool.get("/marco")

  assert_equal "200", res.code
  assert_equal 'polo', res.body

  res = pool.post("/post", 'test=yes', {'X-Fancy-Header' => 'Sometimes'})

  assert_equal "200", res.code
  assert_equal 'this is a test', res.body

  res = pool.put("/put", 'run=fast')

  assert_equal "200", res.code
  assert_equal 'fast', res.body
end
