require 'sinatra'

set :logging, true

get('/') { 'What is up dog!' }
get('/marco') { 'polo' }

post('/post') { 'the post' }
put('/put') { 'the put' }
