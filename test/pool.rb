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

  get '/wait' do
    sleep 5
    "Finally!"
  end

  delete('/delete') {}
}

scope do
  setup do
    @pool = Net::HTTP::Pool.new("http://localhost:4000/")
  end

  test "check that the HTTP verbs do work" do
    @pool.get("/") do |res|
      assert_equal "200", res.code
      assert_equal 'What is up dog!', res.body
    end

    @pool.get("/marco") do |res|
      assert_equal "200", res.code
      assert_equal 'polo', res.body
    end

    @pool.post("/post", 'test=yes', {'X-Fancy-Header' => 'Sometimes'}) do |res|
      assert_equal "200", res.code
      assert_equal 'this is a test', res.body
    end

    @pool.put("/put", 'run=fast') do |res|
      assert_equal "200", res.code
      assert_equal 'fast', res.body
    end

    @pool.delete("/delete") do |res|
      assert_equal "200", res.code
    end
  end

  test "do not block main thread when resource is slow" do
    start = Time.now
    5.times { @pool.get("/wait") {} }
    assert Time.now - start < 20
  end
end
