require './tweetclock'

task 'jobs:work' do 
  # Thanks Adam Wiggins
  # http://adam.heroku.com/past/2010/3/19/consuming_the_twitter_streaming_api/
  url = 'http://stream.twitter.com/1/statuses/sample.json'

  def set_expiration(time)
    if time.sec == 0
      redis.expire time.to_i, MINUTES_TTL
    else
      redis.expire time.to_i, SECONDS_TTL
    end
  end

  def handle_tweet(tweet)
    return unless tweet['text']
    time = Time.parse(tweet['created_at'])
    redis.setnx time.to_i, tweet['id']
    set_expiration(time)
    # puts "#{tweet['user']['screen_name']}: #{tweet['text']}"
    # puts "#{tweet['id']} #{Time.parse(tweet['created_at']).to_i}"
  end

  EventMachine.run do
    http = EventMachine::HttpRequest.new(url).get :head => {
      'Authorization' => [ ENV['TWITTER_USERNAME'],
                           ENV['TWITTER_PASSWORD'] ] }

    buffer = ""

    http.stream do |chunk|
      buffer += chunk
      while line = buffer.slice!(/.+\r?\n/)
        handle_tweet JSON.parse(line)
      end
    end

    http.disconnect { raise "Connection to Twitter Streaming API lost." }
  end
end
