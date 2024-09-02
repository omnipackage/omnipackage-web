# frozen_string_literal: true

class ApplicationController < ::ActionController::Base
  before_action :set_error_context
  before_action :authenticate
  before_action :require_authentication

  attr_reader :current_user, :current_session

  helper_method :current_user, :logged_in?, :current_session, :breadcrumb, :js_variables, :page_title

  private

  def breadcrumb
    @breadcrumb ||= ::Breadcrumb.new(view_context)
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
    @current_session = ::Session.authenticate(cookies)
    return unless @current_session

    @current_session.update(user_agent: request.user_agent, ip_address: request.ip)
    @current_user = @current_session.user
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

  def set_error_context
    ::Rails.error.set_context(user: -> { current_user }, request: request)
  end

  def js_variables
    @js_variables ||= ::JsVariables.new
  end

  def page_title
    "OmniPackage#{breadcrumb.to_page_title_part}"
  end
end
