# frozen_string_literal: true

class DashboardController < ::ApplicationController
  def show
    @dashboard = ::Dashboard.new(current_user)
  end
end
