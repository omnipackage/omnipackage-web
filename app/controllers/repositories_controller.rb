# frozen_string_literal: true

class RepositoriesController < ::ApplicationController
  def index
    @repositories = current_user.repositories.includes(:project)

    breadcrumb.add('Repositories')
  end

  def show # rubocop: disable Metrics/AbcSize
    @repository = find_repository

    breadcrumb.add('Repositories', repositories_path)
    breadcrumb.add(@repository.distro.name)
    breadcrumb.add(@repository.project.name, project_path(@repository.project))
    breadcrumb.add(@repository.id)
  end

  def destroy
    find_repository.destroy!
    redirect_to(repositories_path, notice: 'Repository has been successfully deleted')
  end

  private

  def find_repository
    current_user.repositories.find(params[:id])
  end
end
