class TasksController < ::ApplicationController
  def index # rubocop: disable Metrics/AbcSize
    # if params.key?(:project_id) && params[:project_id].blank?
    # redirect_to(tasks_path)
    # end
    tasks = if project
              project.tasks
            else
              current_user.tasks
            end
    tasks = tasks.by_distro(params[:distro]) if params[:distro].present?
    tasks = tasks.where(state: params[:state]) if params[:state].present?
    @pagination, @tasks = ::Pagination.new(tasks.order(created_at: :desc), self).call

    breadcrumb.add('Tasks')
  end

  def show
    @task = task

    breadcrumb.add('Tasks', tasks_path)
    breadcrumb.add("Task #{@task.id}")
  end

  def create # rubocop: disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    tasks = ::Task::Starter.new(project, skip_fetch: params[:skip_fetch] == 'true', distro_ids: params[:distro_ids].presence).call
    if tasks.empty?
      redirect_back_or_to(tasks_path, alert: 'Pending task already exists, skipping')
    elsif tasks.all?(&:valid?)
      if params[:no_redirect] == 'true'
        redirect_back_or_to(tasks_path)
      elsif tasks.size == 1
        redirect_to(tasks_path(project_id: project.id, highlight: tasks.sole.id))
      else
        redirect_to(tasks_path(project_id: project.id))
      end
    else
      redirect_back_or_to(tasks_path, alert: "Error creating CI task: #{task.find(&:invalid?).errors.full_messages.to_sentence}")
    end
  end

  def destroy
    task.destroy!
    redirect_to(tasks_path, notice: 'Task has been successfully deleted')
  end

  def cancel
    task.cancelled!
    redirect_to(tasks_path, notice: 'Task has been successfully cancelled')
  end

  def log # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    respond_to do |format|
      format.text do
        render(plain: task.log.text)
      end
      format.html do
        @log = task.log

        breadcrumb.add('Tasks', tasks_path)
        breadcrumb.add(task.id, task_path(task))
        breadcrumb.add('Log')
      end
    end
  end

  def publish
    ::RepositoryPublishJob.start(task)
    redirect_to(task_path(task), notice: 'Repository publish job has been successfully started')
  end

  private

  def project
    @project ||= current_user.projects.find_by(id: params[:project_id]) # rubocop: disable Rails/FindByOrAssignmentMemoization
  end

  def task
    @task ||= current_user.tasks.find(params[:id])
  end
end
