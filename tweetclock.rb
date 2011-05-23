require 'sinatra'
require 'eventmachine'
require 'em-http'
require 'json'
require 'sinatra/redis'

SECONDS_TTL =     12 * 60 * 60
MINUTES_TTL = 9 * 24 * 60 * 60

configure :production do
  require 'newrelic_rpm'
  require 'hoptoad_notifier'
end

HoptoadNotifier.configure do |config|
  config.api_key = ENV['HOPTOAD_API_KEY']
end

use HoptoadNotifier::Rack
enable :raise_errors
set :redis, ENV['REDISTOGO_URL']

get '/' do
  redis.get(Time.now.to_i - 5)
end

get '/:api_version/id_at/:posix' do
  if params[:api_version] == '1'
    redis.get params[:posix].to_i
  end
end