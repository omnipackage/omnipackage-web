# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user, class_name: '::User', inverse_of: :projects
  has_one :sources_tarball, class_name: '::Project::SourcesTarball', dependent: :destroy
  has_many :tasks, class_name: '::Task', through: :sources_tarball
  has_many :repositories, class_name: '::Repository', dependent: :destroy
  has_many :webhooks, class_name: '::Webhook', dependent: :destroy

  encrypts :sources_private_ssh_key

  enum :sources_kind, ::Project::Sources.kinds.index_with(&:itself), default: ::Project::Sources.kinds.first
  enum :sources_status, %w[unverified fetching verified].index_with(&:itself), default: 'unverified'

  validates :name, presence: true, length: { maximum: 150 }, format: { with: /\A[A-Za-z0-9 ]+\z/ }
  validates :sources_location, presence: true, length: { maximum: 8000 }
  validates :sources_kind, presence: true
  validates :sources_subdir, length: { maximum: 500 }, format: { without: /\..|\A\// }, allow_blank: true
  validates :sources_branch, length: { maximum: 200 }, format: { without: /\..|\A\// }, allow_blank: true

  broadcast_with ::Broadcasts::Project

  delegate :distros, :distro_ids, :installable_package_name, to: :sources_tarball, allow_nil: true

  def sources
    ::Project::Sources.new(
      kind:             sources_kind,
      location:         sources_location,
      subdir:           sources_subdir,
      branch:           sources_branch,
      ssh_private_key:  sources_private_ssh_key
    )
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
    sources_tarball.present? && verified?
  end

  def sources_verified_at
    sources_tarball&.updated_at
  end

  def default_bucket(distro)
    "#{user.id}-#{safe_name}-#{distro.id}".gsub(/[^0-9a-z]/i, '-')
  end

  def create_default_repository(distro)
    return if repositories.exists?(distro_id: distro.id)

    repositories.create!(distro_id: distro.id, bucket: default_bucket(distro))
  end

  def create_default_repositories
    distros.each do |distro|
      create_default_repository(distro)
    end
  end
end
