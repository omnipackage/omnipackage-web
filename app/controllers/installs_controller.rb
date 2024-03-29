# frozen_string_literal: true

class InstallsController < ::ApplicationController
  skip_before_action :require_authentication
  layout false

  def index
    @project = ::Project.find(params[:project_id])
  end
end
