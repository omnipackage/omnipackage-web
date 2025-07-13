class Task
  class Starter
    def initialize(project, skip_fetch: false, distro_ids: nil)
      @distro_ids = distro_ids || project.distro_ids.presence || ::Distro.active_ids
      @distro_ids &= ::Distro.active_ids
      @project = project
      @skip_fetch = skip_fetch
    end

    def call # rubocop: disable Metrics/MethodLength
      create_source_tarball_if_not_exists

      task = project.tasks.build(distro_ids: distro_ids)
      if skip_fetch && project.sources_verified?
        task.state = 'pending_build'
        task.copy_project_sources!
      else
        task.state = 'pending_fetch'
      end
      if task.save && task.pending_fetch?
        ::SourcesFetchJob.start(project, task)
      end
      task
    end

    def sources_fetched(task)
      return unless task

      task.copy_project_sources!
      task.update!(state: 'pending_build', distro_ids: task.distro_ids & distro_ids)
    end

    private

    attr_reader :project, :skip_fetch, :distro_ids

    def create_source_tarball_if_not_exists
      return if project.sources_tarball

      project.create_sources_tarball!
      project.unverified!
    end
  end
end
