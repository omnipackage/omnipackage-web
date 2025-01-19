class ProjectsController < ::ApplicationController
  def index
    @pagination, @projects = ::Pagination.new(current_user.projects.order(created_at: :desc), self).call

    breadcrumb.add('Projects')
  end

  def show
    @project = find_project

    breadcrumb.add('Projects', projects_path)
    breadcrumb.add(@project.name)
  end

  def new
    @project = build_project

    breadcrumb.add('Projects', projects_path)
    breadcrumb.add('New')

    js_variables.set(:storage_base_url, @project.user.repository_default_storage_config.url)
  end

  def edit
    @project = find_project

    breadcrumb.add('Projects', projects_path)
    breadcrumb.add(@project.name, project_path(@project))
    breadcrumb.add('Edit')
  end

  def create
    @project = build_project
    @project.assign_attributes(project_params)
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
    @project = find_project
    @project.assign_attributes(project_params.except(:slug))
    if @project.save
      if %w[sources_location sources_kind].intersect?(@project.previous_changes.keys)
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

  def project_params
    params.expect(project: [:name, :slug, :sources_location, :sources_kind, :sources_subdir, :sources_branch, :secrets, :description, :upstream_url, :logo, :_remove_logo])
  end
end
