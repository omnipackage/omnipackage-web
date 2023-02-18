# frozen_string_literal: true

class ProjectsController < ::ApplicationController
  def index
    @projects = current_user.projects
  end

  def show
    @project = current_user.projects.find(params[:id])
  end

  def new
    @project = current_user.projects.build
  end

  def edit
    @project = current_user.projects.find(params[:id])
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      redirect_to(projects_path, notice: "Project #{@project.name} created successfully")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @project = current_user.projects.find(params[:id])
  end

  def destroy
    current_user.projects.find(params[:id]).destroy!
    redirect_to(projects_path, notice: 'Project has been successfully deleted')
  end

  private

  def project_params
    params.permit(:name)
  end
end
