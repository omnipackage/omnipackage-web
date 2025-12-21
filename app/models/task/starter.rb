class Task
  class Starter
    def initialize(project, skip_fetch: false, distro_ids: nil)
      @distro_ids = distro_ids || project.distro_ids.presence || ::Distro.active_ids
      @distro_ids &= ::Distro.active_ids
      @project = project
      @skip_fetch = skip_fetch
    end

    def call
      create_source_tarball_if_not_exists

      tasks = build_tasks
      if tasks.all?(&:save) && tasks.all?(&:pending_fetch?)
        ::SourcesFetchJob.start(project, tasks)
      end
      tasks
    end

    def sources_fetched(tasks)
      tasks.each do |task|
        task.copy_project_sources!
        task.update!(state: 'pending_build', distro_ids: task.distro_ids & distro_ids)
      end
    end

    private

    attr_reader :project, :skip_fetch, :distro_ids

    def build_tasks # rubocop: disable Metrics/MethodLength
      tasks = distro_ids.map { project.tasks.build(distro_ids: [it]) }
      if skip_fetch && project.sources_verified?
        tasks.each do |task|
          task.state = 'pending_build'
          task.copy_project_sources!
        end
      else
        tasks.each do |task|
          task.state = 'pending_fetch'
        end
      end
      tasks
    end

    def create_source_tarball_if_not_exists
      return if project.sources_tarball

      project.create_sources_tarball!
      project.unverified!
    end
  end
end
