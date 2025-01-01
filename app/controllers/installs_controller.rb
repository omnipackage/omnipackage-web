class InstallsController < ::ApplicationPublicController
  def index
    @project = ::Project
               .includes(:user, :sources_tarball, :custom_repository_storage)
               .where(slug: params[:project_slug], users: { slug: params[:user_slug] })
               .sole
    @repositories = @project.repositories.ordered.includes(:user)
  end

  protected

  def page_title
    "Install #{@project.name} - OmniPackage"
  end
end
