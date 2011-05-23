require 'sinatra'
require 'eventmachine'
require 'em-http'
require 'json'
require 'sinatra/redis'
require 'active_support/core_ext'


SECONDS_TTL =     12 * 60 * 60
MINUTES_TTL = 9 * 24 * 60 * 60

configure :production do
  require 'newrelic_rpm'
  require 'hoptoad_notifier'

  HoptoadNotifier.configure do |config|
    config.api_key = ENV['HOPTOAD_API_KEY']
  end

  use HoptoadNotifier::Rack
  enable :raise_errors
end

set :redis, ENV['REDISTOGO_URL']

get '/' do
  redis.get(Time.now.to_i - 5)
end

get '/*/id_at/*.*' do |api_version, posix_time, ext|
  if api_version == '1'
    tt = TweetTime.find(posix_time.to_i)
    return if tt.nil?

    case ext
    when 'json'
      tt.to_json
    when 'xml'
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

class TweetTime
  attr_accessor :time, :id

  def initialize(time, id)
    @time, @id = time, id
  end

  def to_h
    {:time => @time, :id => @id}
  end

  def to_json
    to_h.to_json
  end

  def to_xml
    to_h.to_xml
  end

  def self.find(time)
    if (Time.now.to_i - time < SECONDS_TTL)
      new time, redis.get(time)
    else
      near_time = find_nearest(time)
      new near_time, redis.get(near_time)
    end
  end

  private

  def self.find_nearest(time)
    time = Time.at(time)
    if time.sec < 31
      previous_minute(time).to_i
    else
      next_minute(time).to_i
    end
  end

  def self.next_minute(time)
    time + (60 - time.sec)
  end

  def self.previous_minute(time)
    time - time.sec
  end
end