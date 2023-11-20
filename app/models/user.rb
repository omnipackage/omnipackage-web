# frozen_string_literal: true

class User < ::ApplicationRecord
  has_secure_password

  PASSWORD_MIN_LENGTH = 8

  has_many :email_verification_tokens, class_name: '::EmailVerificationToken', dependent: :destroy
  has_many :password_reset_tokens, class_name: '::PasswordResetToken', dependent: :destroy
  has_many :sessions, class_name: '::Session', dependent: :destroy

  has_many :projects, class_name: '::Project', dependent: :destroy
  has_many :repositories, through: :projects, class_name: '::Repository'
  has_many :private_agents, class_name: '::Agent', dependent: :destroy
  has_many :tasks, class_name: '::Task', through: :projects

  validates :email, presence: true, uniqueness: true, format: { with: ::URI::MailTo::EMAIL_REGEXP }, length: { maximum: 300 }
  validates :password, allow_nil: true, length: { minimum: PASSWORD_MIN_LENGTH, maximum: 30 }
  validates :gpg_key_private, :gpg_key_public, presence: true

  encrypts :gpg_key_private

  before_validation if: -> { email.present? } do
    self.email = email.downcase.strip
  end
  before_validation if: :email_changed?, unless: :new_record? do
    self.verified_at = nil
  end
  before_create :generate_gpg_keys

  def verified?
    verified_at.present?
  end

  def gpg_key
    ::Gpg::Key[gpg_key_private, gpg_key_public]
  end

  def generate_gpg_keys
    gpg = ::Gpg.new.generate_keys(email, email)
    self.gpg_key_private = gpg.priv
    self.gpg_key_public = gpg.pub
  end

  def gpg_public_key_info
    ::Gpg.new.key_info(gpg_key.pub)
  end
end
