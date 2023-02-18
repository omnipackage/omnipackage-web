# frozen_string_literal: true

module Identity
  class AccountsController < ::ApplicationController
    def show
      @user = current_user
    end
  end
end
