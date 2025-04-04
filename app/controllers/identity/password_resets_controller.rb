module Identity
  class PasswordResetsController < ::ApplicationController
    skip_before_action :require_authentication

    before_action :set_user, only: %i[edit update]

    def new
    end

    def edit
    end

    def create
      @user = ::User.where(email: params[:email]).where.not(verified_at: nil).first
      if @user
        ::UserMailer.with(user: @user).password_reset.deliver_later
        redirect_to(sign_in_path, notice: 'Check your email for reset instructions')
      else
        redirect_to(new_identity_password_reset_path, alert: "You can't reset your password until you verify your email")
      end
    end

    def update
      if @user.update(user_params)
        @token.destroy
        redirect_to(sign_in_path, notice: 'Your password was reset successfully. Please sign in')
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def set_user
      @token = ::PasswordResetToken.find_signed!(params[:sid])
      @user = @token.user
    rescue ::StandardError
      redirect_to(new_identity_password_reset_path, alert: 'That password reset link is invalid')
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end
  end
end
