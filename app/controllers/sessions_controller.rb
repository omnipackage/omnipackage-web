class SessionsController < ::ApplicationController
  skip_before_action :require_authentication, only: %i[new create]
  before_action :require_no_authentication, only: %i[new create]

  def index
    @pagination, @sessions = ::Pagination.new(current_user.sessions.order(created_at: :desc), self).call
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

  def destroy_all_but_current
    current_user.sessions.where.not(id: current_session).destroy_all
    redirect_to(sessions_path, notice: 'All other sessions have been logged out')
  end
end
