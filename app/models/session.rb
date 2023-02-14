# frozen_string_literal: true

class Session < ::ApplicationRecord
  belongs_to :user

  attribute :user_agent, :string, default: ''
  attribute :ip_address, :string, default: ''

  after_create_commit do
    ::SessionMailer.with(session: self).signed_in_notification.deliver_later
  end
end
