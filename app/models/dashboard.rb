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
    @projects ||= user.projects
  end

  def projects_by_distro(distro_id)
    projects.select { |i| i.distros.map(&:id).include?(distro_id) }
  end
end
