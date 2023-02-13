class ApplicationController < ::ActionController::Base
  before_action :authenticate
  before_action :require_authentication

  attr_reader :current_user, :current_session
  helper_method :current_user, :logged_in?, :current_session

  private

  def sign_in(user)
    @current_session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.ip)
    @current_user = user
    cookies.signed.permanent[:session_token] = { value: @current_session.id, httponly: true }
  end

  def sign_out
    cookies.delete(:session_token)
  end

  def authenticate
    session = ::Session.find_by(id: cookies.signed[:session_token])
    if session
      @current_session = session
      @current_user = session.user
    end
  end

  def require_authentication
    redirect_to(sign_in_path) unless logged_in?
  end

  def require_no_authentication
    redirect_to(root_path, notice: "You're already signed in") if logged_in?
  end

  def logged_in? = current_user.present?
end
