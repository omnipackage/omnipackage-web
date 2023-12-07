# frozen_string_literal: true

class RepositoriesController < ::ApplicationController
  def show
    @repository = find_repository
  end

  private

  def find_repository
    current_user.repositories.find(params[:id])
  end
end
