# frozen_string_literal: true

class ProjectsController < ::ApplicationController
  def index
    @projects = current_user.projects.order(:name)
  end

  def show
    @project = find_project
  end

  def new
    @project = build_project
  end

  def edit
    @project = find_project
  end

  def create
    @project = assign_attributes(build_project)
    if @project.save
      redirect_to(projects_path, notice: "Project #{@project.name} has been successfully created")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @project = assign_attributes(find_project)
    if @project.save
      redirect_to(projects_path, notice: "Project #{@project.name} has been successfully updated")
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    current_user.projects.find(params[:id]).destroy!
    redirect_to(projects_path, notice: 'Project has been successfully deleted')
  end

  private

  def find_project
    current_user.projects.find(params[:id])
  end

  def build_project
    current_user.projects.build
  end

  def assign_attributes(object)
    object.name = params[:name]
    object.sources_location = params[:sources_location]
    object.sources_kind = params[:sources_kind]
    object
  end
end
