# frozen_string_literal: true

class Task
  class Starter
    def initialize(project, skip_fetch: false, distro_ids: nil)
      @distro_ids = distro_ids || project.distro_ids.presence || ::Distro.ids
      @project = project
      @skip_fetch = skip_fetch
    end

    def call
      return if already_exists?

      create_source_tarball_if_not_exists

      task = ::Task.create(
        sources_tarball:  project.sources_tarball,
        state:            skip_fetch && project.sources_verified? ? 'pending_build' : 'pending_fetch',
        distro_ids:       distro_ids
      )
      ::SourcesFetchJob.start(project, task) if task.valid? && task.pending_fetch?
      task
    end

    private

    attr_reader :project, :skip_fetch, :distro_ids

    def already_exists?
      project.sources_verified? && ::Task.exists?(
        sources_tarball_id: project.sources_tarball.id,
        state:              %w[pending_build pending_fetch running],
        distro_ids:         distro_ids
      )
    end

    def create_source_tarball_if_not_exists
      return if project.sources_tarball

      project.create_sources_tarball!
      project.unverified!
    end
  end
end
