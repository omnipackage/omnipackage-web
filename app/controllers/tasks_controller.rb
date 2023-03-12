# frozen_string_literal: true

class TasksController < ::ApplicationController
  def index
    @tasks = if current_user.root?
               ::Task.all
             else
               current_user.tasks
             end.order(created_at: :desc)
  end

  def show
    @task = find_task
  end

  def destroy
    find_task.destroy!
    redirect_to(tasks_path, notice: 'Task has been successfully deleted')
  end

  private

  def find_task
    if current_user.root?
      ::Task.all
    else
      current_user.tasks
    end.find(params[:id])
  end
end
