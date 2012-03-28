# Net::HTTP::Pool

![Pool](http://www.beijingboyce.com/wp-content/uploads/2008/03/pool-table.JPG)

Act like a database pool but for HTTP.

## Example

```ruby
pool = Net::HTTP::Pool.new("http://elcuervo.co")
pool.get("/humans.txt") do |response|
  puts response.body.read if response.code == "200"
end
```
