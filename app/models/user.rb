# frozen_string_literal: true

class User < ::ApplicationRecord
  has_secure_password

  PASSWORD_MIN_LENGTH = 8

  has_many :email_verification_tokens, class_name: '::EmailVerificationToken', dependent: :destroy
  has_many :password_reset_tokens, class_name: '::PasswordResetToken', dependent: :destroy
  has_many :sessions, class_name: '::Session', dependent: :destroy

  has_many :projects, class_name: '::Project', dependent: :destroy
  has_many :private_agents, class_name: '::Agent', dependent: :destroy
  has_many :tasks, class_name: '::Task', through: :projects

  validates :email, presence: true, uniqueness: true, format: { with: ::URI::MailTo::EMAIL_REGEXP }, length: { maximum: 300 }
  validates :password, allow_nil: true, length: { minimum: PASSWORD_MIN_LENGTH, maximum: 30 }

  before_validation if: -> { email.present? } do
    self.email = email.downcase.strip
  end

  before_validation if: :email_changed?, unless: :new_record? do
    self.verified_at = nil
  end

  def verified? = verified_at.present?
end
