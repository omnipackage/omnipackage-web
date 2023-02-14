# frozen_string_literal: true

class Agent < ::RedisRecord
  self.redis_connection = ::Redis.new(url: ::ENV.fetch('REDIS_URL', 'redis://localhost:6379/2'))
  self.redis_key_prefix = 'agents:'
  self.redis_key_suffix = ''
  self.redis_key_attribute = :id

  attr_accessor :id

  def to_hash
    {
      id: id
    }
  end
end
