class CustomRepositoryStoragesController < ::ApplicationController
  def show
    @custom_repository_storage = project.custom_repository_storage || project.build_custom_repository_storage

    breadcrumb.add('Projects', projects_path)
    breadcrumb.add(project.name, project_path(project))
    breadcrumb.add('Custom repository storage')
  end

  def create
    @custom_repository_storage = project.build_custom_repository_storage
    @custom_repository_storage.assign_attributes(custom_repository_storage_params)
    if @custom_repository_storage.valid?
      @custom_repository_storage.save!
      redirect_to(project_path(project), notice: "Project's #{project.name} custom repository storage has been successfully created")
    else
      render(:show, status: :unprocessable_entity)
    end
  end

  def update
    @custom_repository_storage = project.custom_repository_storage
    @custom_repository_storage.assign_attributes(custom_repository_storage_params)
    if @custom_repository_storage.valid?
      @custom_repository_storage.save!
      redirect_to(project_path(project), notice: "Project's #{project.name} custom repository storage has been successfully updated")
    else
      render(:show, status: :unprocessable_entity)
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
    params.expect(project_custom_repository_storage: [:bucket, :path, :endpoint, :access_key_id, :secret_access_key, :region, :path, :bucket_public_url])
  end
end
