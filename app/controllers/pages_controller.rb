class PagesController < ::ApplicationController
  skip_before_action :require_authentication

  ALL = %i[distros]

  ALL.each do |page|
    define_method(page) do
      breadcrumb.add(page.to_s.humanize)
    end
  end

  def deprecated_distro
    @distro = ::Distro[params.fetch(:id)]
  end
end
