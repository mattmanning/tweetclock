require './tweetclock'

task 'jobs:work' do 
  url = 'http://stream.twitter.com/1/statuses/sample.json'

  def handle_tweet(tweet)
    return unless tweet['text']
    puts "#{tweet['user']['screen_name']}: #{tweet['text']}"
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