# frozen_string_literal: true

class RepositoriesController < ::ApplicationController
  def index
    @repositories = current_user.repositories

    breadcrumb.add('Repositories')
  end

  def show
    @repository = find_repository

    breadcrumb.add('Projects', projects_path)
    breadcrumb.add(@repository.project.name, project_path(@repository.project))
    breadcrumb.add(@repository.distro.name)
  end

  private

  def find_repository
    current_user.repositories.find(params[:id])
  end
end
