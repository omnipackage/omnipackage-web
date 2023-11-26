# frozen_string_literal: true

class SourcesController < ::ApplicationController
  def index
    if project.sources_verified?
      send_data(project.sources_tarball.decrypted_tarball, filename: project.sources_tarball.decrypted_tarball_filename)
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
