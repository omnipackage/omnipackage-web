# frozen_string_literal: true

class Dashboard
  attr_reader :user

  def initialize(user)
    @user = user
  end
end
