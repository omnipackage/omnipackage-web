# frozen_string_literal: true

class ProjectsController < ::ApplicationController
  def index
    @projects = current_user.projects
  end

  def show
    @project = current_user.projects.find(params[:id])
  end

  def edit
    @project = current_user.projects.find(params[:id])
  end

  def new
    @project = current_user.projects.build
  end

  def update
    @project = current_user.projects.find(params[:id])
  end

  def create
  end

  def destroy
    current_user.projects.find(params[:id]).destroy!
    redirect_to(projects_path, notice: 'Project has been successfully deleted')
  end
end
