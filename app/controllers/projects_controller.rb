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
    if @project.valid?
      @project.generate_ssh_keys
      @project.save!
      ::SourcesFetchJob.perform_later(@project.id)
      redirect_to(projects_path, notice: "Project #{@project.name} has been successfully created")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @project = assign_attributes(find_project)
    if @project.save
      if %w[sources_location sources_kind].intersect?(@project.previous_changes.keys)
        @project.sources_tarball&.destroy
        ::SourcesFetchJob.perform_later(@project.id)
      end
      redirect_to(project_path(@project.id), notice: "Project #{@project.name} has been successfully updated")
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    current_user.projects.find(params[:id]).destroy!
    redirect_to(projects_path, notice: 'Project has been successfully deleted')
  end

  def generate_ssh_keys
    project = current_user.projects.find(params[:project_id])
    if project.generate_ssh_keys && project.save
      redirect_to(project_path(project.id), notice: "New SSH keys for project #{project.name} have been successfully generated")
    else
      redirect_to(project_path(project.id), alert: "Error generating new SSH keys for project #{project.name}")
    end
  end

  def fetch_sources
    project = current_user.projects.find(params[:project_id])
    ::SourcesFetchJob.perform_later(project.id)
    redirect_to(project_path(project.id), notice: 'A background job has been started')
  end

  def download_tarball
    project = current_user.projects.find(params[:project_id])
    if project.sources_verified?
      send_data(project.sources_tarball.decrypted_tarball, filename: project.sources_tarball.decrypted_tarball_filename)
    else
      redirect_to(project_path(project.id), alert: 'No cached sources')
    end
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
