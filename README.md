# Net::HTTP::Pool

[![Build Status](https://secure.travis-ci.org/elcuervo/net-http-pool.png?branch=master)](http://travis-ci.org/elcuervo/net-http-pool)

![Pool](http://www.beijingboyce.com/wp-content/uploads/2008/03/pool-table.JPG)

Act like a database pool but for HTTP.

It will attenmpt to open (default: 5) persistent connections to a given server.
Then you can make your requests as you want and the pool get recycled.
The implementation it's made throght actors (celluloid) so the behaviour in the
verb block it's async.

The target of the lib it's to provide DB-like pool to handle information
exchange.

## Motivation

The main goal it's to provide a easy to use HTTP pool exploiting HTTP 1.1
persistent connections in a non-blocking way.

## Example

```ruby
require 'net/http/pool'

pool = Net::HTTP::Pool.new("http://elcuervo.co")
request = Net::HTTP::Get.new("/humans.txt")

pool.request(request) do |response|
  File.open('nevermore.txt', 'w') { |f| f << response.body } if response.code == "200"
end
```

## Thanks to

  * [@foca](http://github.com/foca) and [@dcadenas](http://github.com/dcadenas)
    for code-review and corrections.
