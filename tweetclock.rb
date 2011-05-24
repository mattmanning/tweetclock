require 'sinatra'
require 'eventmachine'
require 'em-http'
require 'json'
require 'sinatra/redis'
require 'active_support/core_ext'
require File.expand_path('../models/tweet_time.rb', __FILE__)

SECONDS_TTL =     12 * 60 * 60
MINUTES_TTL = 9 * 24 * 60 * 60

configure :production do
  disable :raise_errors
  require 'newrelic_rpm'
  require 'hoptoad_notifier'

  HoptoadNotifier.configure do |config|
    config.api_key = ENV['HOPTOAD_API_KEY']
  end

  use HoptoadNotifier::Rack
end

configure :development do
  enable :show_exceptions
end

set :redis, ENV['REDISTOGO_URL']

# There's got to be a better way to do this.
get '/' do
    File.read(File.join('public', 'index.html'))
end

get '/test' do
  redis.get(Time.now.to_i - 5)
end

get '/*/id_at/*.*' do |api_version, posix_time, ext|
  if api_version == '1'
    tt = TweetTime.find(posix_time.to_i)
    return if tt.nil?

    case ext
    when 'json'
      content_type 'application/json', :charset => 'utf-8'
      tt.to_json
    when 'xml'
      content_type 'application/xml', :charset => 'utf-8'
      tt.to_xml
    else
      tt.id
    end
  end
end

get '/*/id_at/*' do |api_version, posix_time|
  if api_version == '1'
    tt = TweetTime.find(posix_time.to_i)
    return if tt.nil?
    tt.id
  end
end