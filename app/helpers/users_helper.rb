# frozen_string_literal: true

module UsersHelper
  def user_avatar_url(user)
    if user.avatar.attached?
      url_for(user.avatar)
    else
      "https://www.gravatar.com/avatar/#{::Digest::MD5.hexdigest(user.email)}"
    end
  end
end
