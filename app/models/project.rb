# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user, class_name: '::User', inverse_of: :projects
  has_one :sources_tarball, class_name: '::Project::SourcesTarball', dependent: :destroy
  has_many :tasks, class_name: '::Task', through: :sources_tarball
  has_many :repositories, class_name: '::Repository', dependent: :destroy
  has_many :webhooks, class_name: '::Webhook', dependent: :destroy
  has_one :custom_respository_storage, class_name: '::Project::RepositoryStorage', inverse_of: :project, dependent: :destroy

  encrypts :sources_private_ssh_key

  serialize :secrets, coder: ::Project::Secrets
  encrypts :secrets
  validate { |i| i.errors.add(:secrets, 'invalid secrets') if i.secrets && !i.secrets.valid? }
  normalizes :secrets, with: -> { _1.empty? ? nil : _1 }

  enum :sources_kind, ::Project::Sources.kinds.index_with(&:itself), default: ::Project::Sources.kinds.first
  enum :sources_status, %w[unverified fetching verified].index_with(&:itself), default: 'unverified'

  validates :name, presence: true, length: { maximum: 60 }
  validates :slug, presence: true, length: { maximum: 30 }, format: { with: ::Slug.new(max_len: ::User::SLUG_MAX_LEN).regex }, uniqueness: true
  validates :sources_location, presence: true, length: { maximum: 8000 }
  validates :sources_kind, presence: true
  validates :sources_subdir, length: { maximum: 500 }, format: { without: /\..|\A\// }, allow_blank: true
  validates :sources_branch, length: { maximum: 200 }, format: { without: /\..|\A\// }, allow_blank: true

  before_validation if: -> { slug.blank? }, on: :create do
    self.slug = ::Slug.new(max_len: ::User::SLUG_MAX_LEN).generate(name)
  end

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

  def create_default_repositories
    distros.map do |distro|
      repositories.find_or_create_by!(distro_id: distro.id)
    end
  end

  def sibling_projects_with_ssh_keys
    user.projects.where('id != ? AND NOT (sources_private_ssh_key IS NULL AND sources_public_ssh_key IS NULL)', id)
  end

  def repository_storage_config
    # TODO support custom_respository_storage
    ::Repository::Storage::Config.new(
      client_config: ::StorageClient::Config.default,
      bucket: user.default_bucket,
      path: slug
    )
  end
end
