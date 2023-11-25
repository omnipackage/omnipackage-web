# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user, class_name: '::User', inverse_of: :projects
  has_one :sources_tarball, class_name: '::Project::SourcesTarball', dependent: :destroy
  has_many :tasks, class_name: '::Task', through: :sources_tarball
  has_many :repositories, dependent: :destroy

  encrypts :sources_private_ssh_key

  enum sources_kind: (%w[git] + (::Rails.env.local? ? %w[localfs] : [])).index_with(&:itself), _default: 'git'

  attribute :name, :string, default: ''
  attribute :sources_location, :string
  attribute :sources_subdir, :string, default: ''

  validates :name, presence: true, length: { in: 2..150 }
  validates :sources_location, presence: true, length: { in: 2..8000 }
  validates :sources_kind, presence: true
  validates :sources_subdir, length: { in: 0..500 }, format: { without: /\..|\A\// }

  delegate :distros, :installable_package_name, to: :sources_tarball, allow_nil: true

  def sources
    ::Project::Sources.new(kind: sources_kind, location: sources_location, subdir: sources_subdir, ssh_private_key: sources_private_ssh_key)
  end

  def safe_name
    name.downcase.gsub(/[^0-9a-z]/i, '_')
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
    "#{user.id}-#{safe_name}-#{distro.id}".gsub(/[^0-9a-z]/i, '-')
  end

  def create_default_repository(distro)
    return if repositories.exists?(distro_id: distro.id)

    gpg = user.gpg_key
    repositories.create!(distro_id: distro.id, bucket: default_bucket(distro), gpg_key_public: gpg.pub, gpg_key_private: gpg.priv)
  end

  def create_default_repositories
    distros.each do |distro|
      create_default_repository(distro)
    end
  end
end
