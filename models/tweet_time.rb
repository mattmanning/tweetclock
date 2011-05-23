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