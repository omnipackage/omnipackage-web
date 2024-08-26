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

  normalizes :email, with: ->(i) { i.strip.downcase }

  before_validation if: :email_changed?, unless: :new_record? do
    self.verified_at = nil
  end
  before_validation :generate_gpg_keys, on: :create

  def verified?
    verified_at.present?
  end

  def gpg_key
    ::Gpg::Key[gpg_key_private, gpg_key_public]
  end

  def displayed_name
    name.presence || email
  end

  def generate_gpg_keys
    gpg = ::Gpg.new.generate_keys(displayed_name, email)
    self.gpg_key_private = gpg.priv
    self.gpg_key_public = gpg.pub
  end

  def gravatar_url
    "https://www.gravatar.com/avatar/#{::Digest::MD5.hexdigest(email)}"
  end

  def default_bucket_prefix
    "#{::APP_SETTINGS[:default_repository_bucket_prefix]}#{id}"
  end
end
