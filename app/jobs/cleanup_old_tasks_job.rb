class CleanupOldTasksJob < ::ApplicationJob
  queue_as :long

  def perform
    ::Task.where(updated_at: ...::Time.now.utc - max_age).destroy_all
  end

  private

  def max_age
    2.weeks
  end
end
