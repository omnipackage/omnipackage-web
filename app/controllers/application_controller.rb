# frozen_string_literal: true

class ApplicationController < ::ActionController::Base
  before_action :authenticate
  before_action :require_authentication

  attr_reader :current_user, :current_session

  helper_method :current_user, :logged_in?, :current_session, :breadcrumb

  private

  def breadcrumb
    @breadcrumb ||= ::Breadcrumb.new(view_context)
  end

  def flash_errors(errors)
    error_message = '<ul>' + errors.map { |e| "<li>#{e.full_message}</li>" }.join + '</ul>'
    flash.now[:alert] = error_message.html_safe # rubocop: disable Rails/OutputSafety
  end

  def sign_in(user)
    @current_session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.ip)
    @current_user = user
    cookies.signed.permanent[:session_token] = { value: @current_session.id, httponly: true }
  end

  def sign_out
    cookies.delete(:session_token)
  end

  def authenticate
    session = ::Session.authenticate(cookies)
    return unless session

    @current_session = session
    @current_user = session.user
  end

  def require_authentication
    redirect_to(sign_in_path) unless logged_in?
  end

  def require_no_authentication
    redirect_to(root_path, notice: "You're already signed in") if logged_in?
  end

  def logged_in?
    current_session.present? && current_user.present?
  end

  def set_nocache
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
  end
end
