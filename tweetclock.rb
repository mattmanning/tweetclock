require 'sinatra'
require 'eventmachine'
require 'em-http'
require 'json'
require 'sinatra/redis'
require 'hoptoad_notifier'

HoptoadNotifier.configure do |config|
  config.api_key = ENV['HOPTOAD_API_KEY']
end

use HoptoadNotifier::Rack
enable :raise_errors
set :redis, ENV['REDISTOGO_URL']

get '/' do
  redis.get(Time.now.to_i - 5)
end
