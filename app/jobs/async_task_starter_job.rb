class AsyncTaskStarterJob < ::ApplicationJob
  queue_as :long

  class Error < ::StandardError; end

  def perform(project_id)
    ::SourcesFetchJob.new.perform(project_id)
    project = ::Project.find(project_id)
    if project.sources_verified?
      ::Task::Starter.new(project, skip_fetch: true).call
    else
      raise Error, project.sources_fetch_error.to_s
    end
  end
end
