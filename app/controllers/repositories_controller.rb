# frozen_string_literal: true

class RepositoriesController < ::ApplicationController
  def show
    @repository = find_repository
  end

  def edit
    @repository = find_repository
  end

  def create
    @repository = assign_attributes(build_repository)
    if @repository.valid?
      redirect_to(repositories_path, notice: "Repository #{@repository.name} has been successfully created")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def destroy
    repository = find_repository
    if params[:delete_files]
      repository.delete_bucket!
    end
    repository.destroy!
    redirect_to(project_path(repository.project), notice: 'Repository has been successfully deleted')
  end

  private

  def find_repository
    current_user.repositories.find(params[:id])
  end

  def build_repository
    current_user.repositories.build
  end

  def assign_attributes(object)
    %i[distro_id bucket endpoint access_key_id secret_access_key region].each do |att|
      object.public_send("#{att}=", params[att].presence)
    end
    object
  end
end
