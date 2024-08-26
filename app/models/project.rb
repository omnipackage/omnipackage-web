# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user, class_name: '::User', inverse_of: :projects
  has_one :sources_tarball, class_name: '::Project::SourcesTarball', dependent: :destroy
  has_many :tasks, class_name: '::Task', through: :sources_tarball
  has_many :repositories, class_name: '::Repository', dependent: :destroy
  has_many :webhooks, class_name: '::Webhook', dependent: :destroy

  encrypts :sources_private_ssh_key

  serialize :secrets, coder: ::Project::Secrets
  encrypts :secrets
  validate { |i| i.errors.add(:secrets, 'invalid secrets') if i.secrets && !i.secrets.valid? }
  normalizes :secrets, with: -> { _1.empty? ? nil : _1 }

  enum :sources_kind, ::Project::Sources.kinds.index_with(&:itself), default: ::Project::Sources.kinds.first
  enum :sources_status, %w[unverified fetching verified].index_with(&:itself), default: 'unverified'

  validates :name, presence: true, length: { maximum: 60 }
  validates :slug, presence: true, length: { maximum: 30 }, format: { with: /\A(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]\z/ }, uniqueness: true
  validates :sources_location, presence: true, length: { maximum: 8000 }
  validates :sources_kind, presence: true
  validates :sources_subdir, length: { maximum: 500 }, format: { without: /\..|\A\// }, allow_blank: true
  validates :sources_branch, length: { maximum: 200 }, format: { without: /\..|\A\// }, allow_blank: true

  before_validation :set_slug, if: -> { slug.blank? }, on: :create
  alias_attribute :safe_name, :slug

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

  def default_bucket(distro)
    "#{user.default_bucket_prefix}-#{slug}-#{distro.id}".gsub(/[^0-9a-z]/i, '-')
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

  def sibling_projects_with_ssh_keys
    user.projects.where('id != ? AND NOT (sources_private_ssh_key IS NULL AND sources_public_ssh_key IS NULL)', id)
  end

  private

  def set_slug
    self.slug = name.to_s.parameterize
  end
end
