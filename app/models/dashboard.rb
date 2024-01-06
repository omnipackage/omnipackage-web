# frozen_string_literal: true

class Dashboard
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def distros
    ::Distro.all
  end

  def projects
    @projects ||= user.projects.includes(:sources_tarball)
  end

  def projects_by_distro(distro)
    projects.select { |i| i.distros&.map(&:id)&.include?(distro.id) }
  end
end
