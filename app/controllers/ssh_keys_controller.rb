class SshKeysController < ::ApplicationController
  def create
    if project.generate_ssh_keys && project.save
      redirect_to(project_path(project.id), notice: "New SSH keys for project #{project.name} have been successfully generated")
    else
      redirect_to(project_path(project.id), alert: "Error generating new SSH keys for project #{project.name}")
    end
  end

  def copy # rubocop: disable Metrics/AbcSize
    from_project = current_user.projects.find(params[:from_project_id])

    project.sources_private_ssh_key = from_project.sources_private_ssh_key
    project.sources_public_ssh_key = from_project.sources_public_ssh_key

    if project.save
      redirect_to(project_path(project), notice: "SSH keys for project #{project.name} have been successfully copied from #{from_project.name}")
    else
      redirect_to(project_path(project), alert: "Error copying SSH keys: #{project.errors.full_messages.to_sentence}")
    end
  end

  private

  def project
    @project ||= current_user.projects.find(params[:project_id])
  end
end
