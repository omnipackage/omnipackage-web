# frozen_string_literal: true

class HomeController < ::ApplicationController
  skip_before_action :require_authentication

  def index
    if logged_in?
      @dashboard = ::Dashboard.new(current_user)
    end
  end
end
