# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user

  encrypts :sources_private_ssh_key

  enum sources_kind: %w[git].index_with(&:itself), _default: 'git'

  attribute :name, :string, default: ''
  attribute :sources_location, :string

  validates :name, presence: true, length: { in: 2..150 }
  validates :sources_location, presence: true, length: { in: 2..8000 }
  validates :sources_kind, presence: true

  def sources
    ::Project::Sources.new(kind: sources_kind, location: sources_location, ssh_private_key: sources_private_ssh_key)
  end

  def generate_ssh_keys
    keys = ::SshKeygen.new.generate
    if keys
      self.sources_private_ssh_key = keys.priv
      self.sources_public_ssh_key = keys.pub
      true
    else
      false
    end
  end

  def sources_verified?
    sources_verified_at.present?
  end

  def sources_verified!
    update!(sources_verified_at: ::Time.now.utc)
  end

  def sources_unverified!
    update!(sources_verified_at: nil)
  end
end
