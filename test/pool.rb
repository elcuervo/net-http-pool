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
    request = Net::HTTP::Get.new("/")

    @pool.request(request) do |res|
      assert_equal "200", res.code
      assert_equal 'What is up dog!', res.body
    end

    request = Net::HTTP::Get.new("/marco")

    @pool.request(request) do |res|
      assert_equal "200", res.code
      assert_equal 'polo', res.body
    end

    request = Net::HTTP::Post.new("/post")
    request.body = 'test=test'
    request['X-Fancy-Header'] = 'Sometimes'

    @pool.request(request) do |res|
      assert_equal "200", res.code
      assert_equal 'this is a test', res.body
    end

    request = Net::HTTP::Put.new("/put")
    request.body = 'run=fast'

    @pool.request(request) do |res|
      assert_equal "200", res.code
      assert_equal 'fast', res.body
    end

    request = Net::HTTP::Delete.new("/delete")
    @pool.request(request) do |res|
      assert_equal "200", res.code
    end
  end

  test "do not block main thread when resource is slow" do
    start = Time.now
    request = Net::HTTP::Get.new("/wait")
    5.times { @pool.request(request) {} }
    assert Time.now - start < 20
  end
end
