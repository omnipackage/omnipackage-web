# frozen_string_literal: true

class RedisRecord
  include ::ActiveModel::Model
  include ::ActiveModel::Validations

  class << self # rubocop: disable Metrics/BlockLength
    def find(key)
      return unless key

      data = redis_connection.get(redis_key(key))
      return unless data

      new(::JSON.parse(data, symbolize_names: true))
    end

    def exists?(key)
      redis_connection.exists?(redis_key(key))
    end

    def all # rubocop: disable Metrics/MethodLength
      result = []
      uniq_keys = ::Set.new
      keys_in_batches do |keys|
        filtered_keys = keys.select { |k| uniq_keys.exclude?(k) }
        uniq_keys.merge(filtered_keys)
        data = redis_connection.multi do |multi|
          keys.map { |k| multi.get(k) }
        end
        data.each { |i| result << new(::JSON.parse(i, symbolize_names: true)) }
      end
      result
    end

    def destroy_all
      keys_in_batches do |keys|
        redis_connection.multi do |multi|
          keys.each { |k| multi.del(k) }
        end
      end
    end

    def redis_connection
      @redis_connection || (raise "you must provide a redis connection via `redis_connection=` method in your class `#{name}`")
    end

    def redis_key_attribute
      @redis_key_attribute || (raise "you must provide a redis key attr via `redis_key_attribute=` method in your class `#{name}`")
    end

    def redis_key_prefix
      @redis_key_prefix || (raise "you must provide a redis key prefix via `redis_key_prefix=` method in your class `#{name}`")
    end

    def redis_key_suffix
      @redis_key_suffix || (raise "you must provide a redis key suffix via `redis_key_suffix=` method in your class `#{name}`")
    end

    def redis_key(key_attribute_value)
      "#{redis_key_prefix}#{key_attribute_value}#{redis_key_suffix}"
    end

    def redis_key_mask
      @redis_key_mask ||= "#{redis_key_prefix}*#{redis_key_suffix}"
    end

    attr_writer :redis_connection, :redis_key_prefix, :redis_key_suffix, :redis_key_attribute

    def keys_in_batches(count: 10_000)
      position = 0
      loop do
        result = redis_connection.scan(position, match: redis_key_mask, count: count)
        position = result.first.to_i
        yield(result.second)
        break if position.zero?
      end
    end
  end

  def save(ttl: nil)
    return false if invalid?
    raise ::ArgumentError, "your class `#{self.class}` must have `to_hash` method to serialize itself" unless respond_to?(:to_hash)

    if redis.set(key, ::JSON.generate(to_hash)) == 'OK'
      update_ttl(ttl)
      true
    else
      false
    end
  end

  def destroy
    redis.del(key)
  end

  def expire_at
    value = redis.ttl(key)
    return if value.negative?

    ::Time.now.utc + value.seconds
  end

  def update_ttl(value)
    return unless value

    redis.expire(key, value.to_i)
  end

  def persistent?
    found = self.class.find(send(self.class.redis_key_attribute))
    found && found.to_hash == to_hash
  end

  private

  def redis
    self.class.redis_connection
  end

  def key
    self.class.redis_key(send(self.class.redis_key_attribute))
  end
end
