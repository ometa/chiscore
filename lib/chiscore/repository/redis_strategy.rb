require 'redis'
require 'uri'

module ChiScore
  class RedisStrategy
    LOCK_TIME = 25 * 60    # 25 min, in seconds

    def self.save_race_start
      redis.sadd("race_start", Time.now.to_i) if fetch_race_start.nil?
    end

    def self.fetch_race_start
      redis.smembers("race_start").first
    end

    def self.check_in!(checkpoint_id, team_id)
      redis.rpush("team_checkins:#{team_id}", checkpoint_id)
      redis.hset("checkins:#{checkpoint_id}", team_id, Time.now.to_i)
      redis.sadd("active:#{checkpoint_id}", team_id)
      redis.setex("time:#{checkpoint_id}:#{team_id}", LOCK_TIME, checkpoint_id)
      redis.setex("locks:#{team_id}", LOCK_TIME, "")
    end

    def self.team_checkins(team_id)
      redis.lrange("team_checkins:#{team_id}", 0, 10)
    end

    def self.team_checkouts(team_id)
      redis.lrange("team_checkouts:#{team_id}", 0, 10)
    end

    def self.active_for(checkpoint_id)
      redis.smembers("active:#{checkpoint_id}")
    end

    def self.checkins_for(checkpoint_id)
      _time_to_integer redis.hgetall("checkins:#{checkpoint_id}")
    end

    def self.team_checkin(checkpoint_id, team_id)
      val = redis.hget("checkins:#{checkpoint_id}", team_id.to_s)
      if val
        val.to_i
      else
        nil
      end
    end

    def self.checkouts_for(checkpoint_id)
      _time_to_integer(redis.hgetall("checkouts:#{checkpoint_id}"))
    end

    def self.team_checkout(checkpoint_id, team_id)
      redis.hget("checkouts:#{checkpoint_id}", team_id.to_s).to_i
    end

    def self.time_for(checkpoint_id, team_id)
      redis.ttl("time:#{checkpoint_id}:#{team_id}")
    end

    def self.check_out!(checkpoint_id, team_id)
      redis.rpush("team_checkouts:#{team_id}", checkpoint_id)
      redis.hset("checkouts:#{checkpoint_id}", team_id, Time.now.to_i)
      redis.srem("active:#{checkpoint_id}", team_id)
      redis.del("locks:#{team_id}")
      redis.del("time:#{checkpoint_id}:#{team_id}")
    end

    def self.destroy_checkin!(checkpoint_id, team_id)
      redis.srem("active:#{checkpoint_id}", team_id)
      redis.del("locks:#{team_id}")
      redis.del("time:#{checkpoint_id}:#{team_id}")
      redis.del("checkins:#{checkpoint_id}", team_id)
      redis.lrem("team_checkouts:#{team_id}", 1, checkpoint_id)
      redis.lrem("team_checkins:#{team_id}", 1, checkpoint_id)
    end

    def self.lock(team_id)
      redis.ttl("locks:#{team_id}")
    end

    def self.redis
      if ENV['REDISTOGO_URL']
        uri = ::URI.parse(ENV["REDISTOGO_URL"])
        @_redis_client ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
        @_redis_client ||= Redis.new
      end
    end

    def self.flag!(checkpoint, team)
      redis.hset("flags:#{checkpoint.id}", team.id, Time.now.to_i)
    end

    def self.find_flags(checkpoint)
      redis.hgetall("flags:#{checkpoint.id}")
    end

    def self.redis=(client)
      @_redis_client = client
    end

  private

    def self._time_to_integer(result)
      result.reduce({}) do |acc, (key, time)|
        acc.merge(key => time.to_i)
      end
    end
  end
end
