class AsyncTaskStarterJob < ::ApplicationJob
  queue_as :long

  class Error < ::StandardError; end

  def perform(project_id)
    ::SourcesFetchJob.new.perform(project_id)
    project = ::Project.find(project_id)
    if project.sources_verified?
      task = ::Task::Starter.new(project, skip_fetch: true).call
      if task.invalid?
        raise Error, task.errors.full_messages.to_sentence
      end
    else
      raise Error, project.sources_fetch_error.to_s
    end
  end
end
