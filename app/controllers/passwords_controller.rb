# frozen_string_literal: true

class PasswordsController < ::ApplicationController
  before_action :set_user

  def edit
  end

  def update # rubocop: disable Metrics/AbcSize
    if !@user.authenticate(params[:current_password])
      redirect_to(edit_password_path, alert: 'The current password you entered is incorrect')
    elsif @user.update(user_params)
      @user.sessions.where.not(id: current_session.id).destroy_all
      redirect_to(root_path, notice: 'Your password has been changed')
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.permit(:password, :password_confirmation)
  end
end
