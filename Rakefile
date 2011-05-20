require './tweetclock'

task 'jobs:work' do 
  url = 'http://stream.twitter.com/1/statuses/sample.json'

  def handle_tweet(tweet)
    return unless tweet['text']
    redis.setnx Time.parse(tweet['created_at']).to_i, tweet['id']
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
  end
end