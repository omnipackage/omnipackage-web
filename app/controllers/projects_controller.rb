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
    @project = assign_attributes(current_user.projects.build)
    if @project.save
      redirect_to(projects_path, notice: "Project #{@project.name} created successfully")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @project = assign_attributes(current_user.projects.find(params[:id]))
    if @project.save
      redirect_to(projects_path, notice: "Project #{@project.name} updated successfully")
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    current_user.projects.find(params[:id]).destroy!
    redirect_to(projects_path, notice: 'Project has been successfully deleted')
  end

  private

  def assign_attributes(object)
    object.name = params[:name]
    object.project_distros = params[:project_distros].reject(&:empty?).map { |i| object.project_distros.find_or_initialize_by(distro_id: i) }
    object
  end
end
