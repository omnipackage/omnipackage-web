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

  class RouteConstraint
    def initialize(meth)
      @meth = meth
    end

    def matches?(request)
      cookies = ::ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
      user = ::Session.authenticate(cookies)&.user
      return false unless user
      user.public_send(@meth)
    end
  end

  private

  def notify
    ::SessionMailer.with(session: self).signed_in_notification.deliver_later
  end
end
