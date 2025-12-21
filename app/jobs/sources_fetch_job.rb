class SourcesFetchJob < ::ApplicationJob
  queue_as :long

  class << self
    def start(project, tasks = [])
      return if project.fetching?

      project.fetching!
      perform_later(project.id, tasks.select(&:pending_fetch?).map(&:id))
    end
  end

  def perform(project_id, task_ids = [])
    project = ::Project.find(project_id)
    tasks = ::Task.where(id: task_ids)
    source = project.sources.sync

    return error!(project, 'no sources') if !source
    return error!(project, 'no build config') if !source.config
    return error!(project, 'no sources tarball') if !source.tarball

    success!(project, source, tasks)
  rescue ::StandardError => e
    error!(project, e.message)
  end

  private

  def success!(project, source, tasks) # rubocop: disable Metrics/MethodLength
    project.transaction do
      tb = project.sources_tarball || project.build_sources_tarball
      tb.upload_tarball(source.tarball)
      tb.config = source.config
      tb.save!
      project.reload
      project.sources_tarball.reload
      project.sources_fetch_error = nil
      project.verified!
      project.create_default_repositories
    end
    ::Task::Starter.new(project).sources_fetched(tasks)
  end

  def error!(project, error_message)
    project.transaction do
      project.sources_fetch_error = error_message
      project.unverified!
    end
  end
end
