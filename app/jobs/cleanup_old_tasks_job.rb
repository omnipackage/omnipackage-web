# frozen_string_literal: true

class CleanupOldTasksJob < ::ApplicationJob
  queue_as :long

  def perform
    raise 'test exception in sidekiq'
    ::Task.where(updated_at: ...::Time.now.utc - 1.month).destroy_all
  end
end
