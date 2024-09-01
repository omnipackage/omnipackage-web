# frozen_string_literal: true

class CustomRepositoryStoragesController < ::ApplicationController
  def new
    @custom_repository_storage = project.build_custom_repository_storage

    breadcrumb.add('Projects', projects_path)
    breadcrumb.add('Custom repository storage')
    breadcrumb.add('New')
  end

  def edit
    @custom_repository_storage = project.custom_repository_storage

    breadcrumb.add('Projects', projects_path)
    breadcrumb.add('Custom repository storage')
    breadcrumb.add('Edit')
  end

  def create
    @custom_repository_storage = project.build_custom_repository_storage
    @custom_repository_storage.assign_attributes(custom_repository_storage_params)
    if @custom_repository_storage.valid?
      @custom_repository_storage.save!
      redirect_to(project_path(project), notice: "Project's #{project.name} custom repository storage has been successfully created")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @custom_repository_storage = project.custom_repository_storage
    @custom_repository_storage.assign_attributes(custom_repository_storage_params)
    if @custom_repository_storage.valid?
      @custom_repository_storage.save!
      redirect_to(project_path(project), notice: "Project's #{project.name} custom repository storage has been successfully updated")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def destroy
    project.custom_repository_storage.destroy!
    redirect_to(project_path(project), notice: 'The project now uses default repository storage')
  end

  private

  def project
    @project ||= current_user.projects.find(params[:project_id])
  end

  def custom_repository_storage_params
    params.require(:project_custom_repository_storage).permit(:bucket, :path, :endpoint, :access_key_id, :secret_access_key, :region)
  end
end
