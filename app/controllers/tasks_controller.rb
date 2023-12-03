# frozen_string_literal: true

class TasksController < ::ApplicationController
  def index
    tasks = if project
              project.tasks
            else
              current_user.tasks
            end
    @pagination, @tasks = ::Pagination.new(tasks.order(created_at: :desc), self).call
  end

  def show
    @task = task
  end

  def create
    task = ::Task.create!(sources_tarball: project.sources_tarball)
    redirect_to(project_tasks_path(project, highlight: task.id))
  end

  def destroy
    find_task.destroy!
    redirect_to(tasks_path, notice: 'Task has been successfully deleted')
  end

  def log
    render(plain: task.log.text)
  end

  private

  def project
    @project ||= current_user.projects.find_by(id: params[:project_id])
  end

  def task
    @task ||= current_user.tasks.find(params[:id])
  end
end
