# frozen_string_literal: true

class ProjectsController < ::ApplicationController
  def index
    @pagination, @projects = ::Pagination.new(current_user.projects.order(:name), self).call
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
        ::SourcesFetchJob.start(@project)
      end
      redirect_to(project_path(@project.id), notice: "Project #{@project.name} has been successfully updated")
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    find_project.destroy!
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
    object.sources_subdir = params[:sources_subdir]
    object
  end
end
