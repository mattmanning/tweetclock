require 'sinatra'
require 'eventmachine'
require 'em-http'
require 'json'
require 'sinatra/redis'

set :redis, ENV['REDISTOGO_URL']

get '/' do
  redis.get(Time.now.to_i - 5)
end
