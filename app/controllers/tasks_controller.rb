# frozen_string_literal: true

class TasksController < ::ApplicationController
  def index
    @pagination, @tasks = ::Pagination.new(current_user.tasks.order(created_at: :desc), self).call
  end

  def show
    @task = current_user.tasks.find(params[:id])
  end

  def create
    project = current_user.projects.find(params[:project_id])
    ::Task.create!(sources_tarball: project.sources_tarball)
    redirect_to(tasks_path, notice: 'Task has been successfully created')
  end

  def destroy
    find_task.destroy!
    redirect_to(tasks_path, notice: 'Task has been successfully deleted')
  end
end
