# frozen_string_literal: true

module Identity
  class AccountsController < ::ApplicationController
    def show
      @user = current_user

      breadcrumb.add('Account')
    end

    def update
      @user = current_user
      @user.update!(user_params)

      redirect_to(identity_account_path)
    end

    private

    def user_params
      params.require(:user).permit(:name)
    end
  end
end
