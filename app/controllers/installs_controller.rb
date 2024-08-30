# frozen_string_literal: true

class InstallsController < ::ApplicationController
  skip_before_action :require_authentication
  layout false

  def index
    @project = ::User.find_by!(slug: params[:user_slug]).projects.find_by!(slug: params[:project_slug])
  end
end
