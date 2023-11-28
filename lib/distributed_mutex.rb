# frozen_string_literal: true

class DistributedMutex
  class LockTimeoutError < ::RuntimeError; end

  def initialize(redis_url = nil)
    @lock_manager = if redis_url
                      ::Redlock::Client.new([redis_url])
                    else
                      ::Redlock::Client.new
                    end
  end

  def with_lock(key, timeout_sec:, wait_sec:) # rubocop: disable Metrics/MethodLength
    started_at = current_monotonic_time

    loop do
      li = lock_manager.lock(key, timeout_sec * 1000)
      if li
        begin
          return yield
        ensure
          lock_manager.unlock(li)
        end
      else
        if (current_monotonic_time - started_at) > wait_sec
          raise LockTimeoutError, "cannot acquire lock for '#{key}' in #{wait_sec} seconds"
        else
          sleep(0.5)
        end
      end
    end
  end

  private

  attr_reader :lock_manager

  def current_monotonic_time
    ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
  end
end
