# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user
  has_one :sources_tarball, class_name: '::Project::SourcesTarball', dependent: :destroy
  has_many :tasks, class_name: '::Task', through: :sources_tarball
  has_many :repositories, dependent: :destroy

  encrypts :sources_private_ssh_key

  enum sources_kind: (%w[git] + (::Rails.env.local? ? %w[localfs] : [])).index_with(&:itself), _default: 'git'

  attribute :name, :string, default: ''
  attribute :sources_location, :string

  validates :name, presence: true, length: { in: 2..150 }
  validates :sources_location, presence: true, length: { in: 2..8000 }
  validates :sources_kind, presence: true

  delegate :distros, to: :sources_tarball, allow_nil: true

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
    sources_tarball.present?
  end

  def sources_verified_at
    sources_tarball&.updated_at
  end

  def default_bucket(distro)
    "#{user.id}-#{distro.id}".gsub(/[^0-9a-z]/i, '-')
  end

  def create_default_repositories
    distros.each do |dist|
      next if repositories.exists?(distro_id: dist.id)

      repositories.create!(distro_id: dist.id, bucket: default_bucket(dist)).generate_gpg_keys
    end
  end
end
