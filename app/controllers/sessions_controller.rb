# frozen_string_literal: true

class SessionsController < ::ApplicationController
  skip_before_action :require_authentication, only: %i[new create]
  before_action :require_no_authentication, only: %i[new create]

  def index
    @sessions = current_user.sessions.order(created_at: :desc)
  end

  def new
  end

  def create
    user = ::User.authenticate_by(email: params[:email], password: params[:password])
    if user
      sign_in(user)

      redirect_to(root_path, notice: 'Signed in successfully')
    else
      redirect_to(sign_in_path(email_hint: params[:email]), alert: 'That email or password is incorrect')
    end
  end

  def destroy
    session = current_user.sessions.find(params[:id])
    session.destroy
    sign_out if session == current_session
    redirect_to(root_path, notice: 'That session has been logged out')
  end
end
