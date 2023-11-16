# frozen_string_literal: true

class SshKeysController < ::ApplicationController
  def create
    if project.generate_ssh_keys && project.save
      redirect_to(project_path(project.id), notice: "New SSH keys for project #{project.name} have been successfully generated")
    else
      redirect_to(project_path(project.id), alert: "Error generating new SSH keys for project #{project.name}")
    end
  end

  private

  def project
    @project ||= current_user.projects.find(params[:project_id])
  end
end
