# frozen_string_literal: true

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

  def create # rubocop: disable Metrics/AbcSize
    task = ::Task::Starter.new(project, skip_fetch: params[:skip_fetch] == 'true', distro_ids: params[:distro_ids].presence).call
    if task.nil?
      redirect_back(fallback_location: tasks_path, alert: 'Pending task already exists, skipping')
    elsif task.valid?
      redirect_to(tasks_path(project_id: project.id, highlight: task.id))
    else
      redirect_back(fallback_location: tasks_path, alert: "Error creating CI task: #{task.errors.full_messages.to_sentence}")
    end
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

  private

  def project
    @project ||= current_user.projects.find_by(id: params[:project_id])
  end

  def task
    @task ||= current_user.tasks.find(params[:id])
  end
end
