# frozen_string_literal: true

class RegistrationsController < ::ApplicationController
  skip_before_action :require_authentication
  before_action :require_no_authentication
  before_action :check_registration_open

  def new
    @user = ::User.new
    js_variables.set(:storage_base_url, ::StorageClient.build_default.build_url)
  end

  def create
    @user = ::User.new(user_params)

    if @user.save
      sign_in(@user)

      send_email_verification(@user)
      redirect_to(root_path, notice: 'Welcome! You have signed up successfully')
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def user_params
    params.permit(:email, :name, :slug, :password, :password_confirmation)
  end

  def send_email_verification(user)
    ::UserMailer.with(user: user).email_verification.deliver_later
  end

  def check_registration_open
    redirect_to(root_path, alert: 'Registration is not open yet') if ::APP_SETTINGS[:disable_registration]
  end
end
