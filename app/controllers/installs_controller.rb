# frozen_string_literal: true

class InstallsController < ::ApplicationController
  skip_before_action :require_authentication
  layout false

  def index
    @project = ::Project.joins(:user).where(slug: params[:project_slug], users: { slug: params[:user_slug] }).sole
  end
end
