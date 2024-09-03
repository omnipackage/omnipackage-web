# frozen_string_literal: true

class CleanupOldTasksJob < ::ApplicationJob
  queue_as :long

  def perform
    ::Task.where(updated_at: ...::Time.now.utc - 1.month).destroy_all
  end
end
