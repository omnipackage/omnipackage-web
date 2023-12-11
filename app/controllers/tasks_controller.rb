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
    task = ::Task.create!(project: project)
    redirect_to(project_tasks_path(project, highlight: task.id))
  end

  def destroy
    task.destroy!
    redirect_to(tasks_path, notice: 'Task has been successfully deleted')
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
