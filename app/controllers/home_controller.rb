# frozen_string_literal: true

class HomeController < ::ApplicationController
  def index
    @dashboard = ::Dashboard.new(current_user)
  end
end
