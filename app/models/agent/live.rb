# frozen_string_literal: true

class Agent
  class Live < ::RedisRecord
    self.redis_connection = ::Redis.new(url: ::ENV.fetch('REDIS_URL', 'redis://localhost:6379/2'))
    self.redis_key_prefix = 'agentslive:'
    self.redis_key_suffix = ''
    self.redis_key_attribute = :apikey

    attr_accessor :apikey, :payload

    def to_hash
      {
        apikey: apikey,
        payload: payload
      }.freeze
    end
  end
end
