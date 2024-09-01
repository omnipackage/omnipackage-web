# frozen_string_literal: true

class InstallsController < ::PublicApplicationController
  def index
    @project = ::Project
               .includes(:user, :sources_tarball, :custom_respository_storage)
               .where(slug: params[:project_slug], users: { slug: params[:user_slug] })
               .sole
    @repositories = @project.repositories.published.ordered.includes(:user)
  end

  protected

  def page_title
    "Install #{@project.name} - OmniPackage"
  end
end
