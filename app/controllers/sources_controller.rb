class SourcesController < ::ApplicationController
  def index
    if project.sources_verified?
      redirect_to(project.sources_tarball.tarball.url(expires_in: 15.seconds), allow_other_host: true)
    else
      redirect_to(project_path(project.id), alert: 'No cached sources')
    end
  end

  def create
    ::SourcesFetchJob.start(project)
  end

  private

  def project
    @project ||= current_user.projects.find(params[:project_id])
  end
end
