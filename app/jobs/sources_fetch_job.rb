# frozen_string_literal: true

class SourcesFetchJob < ::ApplicationJob
  queue_as :long

  class << self
    def start(project, task = nil)
      return if project.fetching?
      return if task && !task.pending_fetch?

      project.fetching!
      perform_later(project.id, task&.id)
    end
  end

  def perform(project_id, task_id = nil)
    project = ::Project.find(project_id)
    task = ::Task.find(task_id) if task_id
    source = project.sources.sync

    return error!(project, 'no sources') if !source
    return error!(project, 'no build config') if !source.config
    return error!(project, 'no sources tarball') if !source.tarball

    success!(project, source, task)
  rescue ::StandardError => e
    error!(project, e.message)
  end

  private

  def success!(project, source, task)
    project.transaction do
      tb = project.sources_tarball || project.build_sources_tarball
      tb.upload_tarball(source.tarball)
      tb.config = source.config
      tb.save!
      project.sources_fetch_error = nil
      project.verified!
      project.create_default_repositories
      ::Task::Starter.new(project).sources_fetched(task)
    end
  end

  def error!(project, error_message)
    project.transaction do
      project.sources_fetch_error = error_message
      project.unverified!
    end
  end
end
