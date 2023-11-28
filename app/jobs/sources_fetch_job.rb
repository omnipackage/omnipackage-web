# frozen_string_literal: true

class SourcesFetchJob < ::ApplicationJob
  queue_as :long

  class << self
    def start(project)
      return if project.fetching?

      project.fetching!
      perform_later(project.id)
    end
  end

  def perform(project_id)
    project = ::Project.find(project_id)
    source = project.sources.sync

    return error!(project, 'no sources') if !source
    return error!(project, 'no build config') if !source.config
    return error!(project, 'no sources tarball') if !source.tarball

    success!(project, source)
  rescue ::StandardError => e
    error!(project, e.message)
  end

  private

  def success!(project, source)
    project.transaction do
      tb = project.sources_tarball || project.build_sources_tarball
      tb.tarball = source.tarball
      tb.config = source.config
      tb.save!
      project.sources_fetch_error = nil
      project.verified!
      project.create_default_repositories
    end
  end

  def error!(project, error_message)
    project.transaction do
      project.sources_fetch_error = error_message
      project.unverified!
    end
  end
end
