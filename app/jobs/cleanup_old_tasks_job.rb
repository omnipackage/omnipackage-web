class CleanupOldTasksJob < ::ApplicationJob
  queue_as :long

  def perform
    ::Task
      .where(updated_at: ...(::Time.now.utc - max_age))
      .where.not(id: ::Task.select('DISTINCT ON (project_id) id').order(:project_id, updated_at: :desc, id: :desc))
      .destroy_all
  end

  private

  def max_age
    2.weeks
  end
end
