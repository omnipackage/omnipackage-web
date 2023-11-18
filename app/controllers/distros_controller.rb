# frozen_string_literal: true

class DistrosController < ::ApplicationController
  skip_before_action :require_authentication

  def index
    @distros = ::Distro.all
  end
end
