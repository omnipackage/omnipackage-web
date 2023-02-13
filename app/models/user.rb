# frozen_string_literal: true

class User < ::ApplicationRecord
  has_secure_password

  PASSWORD_MIN_LENGTH = 8

  has_many :email_verification_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy

  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: ::URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: PASSWORD_MIN_LENGTH }

  before_validation if: -> { email.present? } do
    self.email = email.downcase.strip
  end

  before_validation if: :email_changed?, unless: :new_record? do
    self.verified_at = nil
  end

  def verified? = verified_at.present?
end
