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
  end

  def show
    @task = task
  end

  def create
    distros = params[:distro_ids].presence || ::Distro.ids
    task = ::Task.start(project, distro_ids: distros)
    redirect_to(tasks_path(project_id: project.id, highlight: task.id))
  end

  def cancel
    task.cancelled!
    redirect_to(tasks_path, notice: 'Task has been successfully cancelled')
  end

  def log
    respond_to do |format|
      format.text do
        render(plain: task.log.text)
      end
      format.html do
        @log = task.log
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
