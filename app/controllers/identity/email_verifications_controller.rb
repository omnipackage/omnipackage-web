module Identity
  class EmailVerificationsController < ::ApplicationController
    skip_before_action :require_authentication, only: :edit

    before_action :set_user, only: :edit

    def edit
      @user.update!(verified_at: ::Time.now.utc)
      redirect_to(root_path, notice: 'Thank you for verifying your email address')
    end

    def create
      ::UserMailer.with(user: current_user).email_verification.deliver_later
      redirect_to(root_path, notice: 'We sent a verification email to your email address')
    end

    private

    def set_user
      @token = ::EmailVerificationToken.find_signed!(params[:sid])
      @user = @token.user
    rescue
      redirect_to(edit_identity_email_path, alert: 'That email verification link is invalid')
    end
  end
end
