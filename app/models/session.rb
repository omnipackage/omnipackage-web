# frozen_string_literal: true

class Session < ::ApplicationRecord
  belongs_to :user, class_name: '::User'

  attribute :user_agent, :string, default: ''
  attribute :ip_address, :string, default: ''

  after_create_commit :notify

  class << self
    def authenticate(cookies)
      find_by(id: cookies.signed[:session_token])
    end
  end

  private

  def notify
    ::SessionMailer.with(session: self).signed_in_notification.deliver_later
  end
end
