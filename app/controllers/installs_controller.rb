# frozen_string_literal: true

class InstallsController < ::PublicApplicationController
  def index
    @project = ::Project.joins(:user).where(slug: params[:project_slug], users: { slug: params[:user_slug] }).sole
  end

  protected

  def page_title
    "Install #{@project.name} - OmniPackage"
  end
end
