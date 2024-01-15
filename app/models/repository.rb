# frozen_string_literal: true

class Repository < ::ApplicationRecord
  belongs_to :project, class_name: '::Project', inverse_of: :repositories
  has_one :user, through: :project, class_name: '::User'

  validates :distro_id, inclusion: { in: ::Distro.ids }
  validates :gpg_key_private, :gpg_key_public, presence: true, allow_nil: true
  validates :bucket, presence: true, format: /(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]\z/, uniqueness: { scope: :endpoint }
  validates :region, :endpoint, :access_key_id, :secret_access_key, presence: true, if: -> { custom_storage? }
  validates_with ::Repository::RepositoryValidator, unless: -> { ::Rails.env.test? }

  encrypts :gpg_key_private, :secret_access_key

  enum :publish_status, %w[pending publishing published].index_with(&:itself), default: 'pending'

  broadcast_with ::Broadcasts::Repository

  after_destroy_commit { ::DeleteBucketJob.perform_later(storage_client.config, bucket) }

  scope :without_own_gpg_key, -> { where(gpg_key_private: nil, gpg_key_public: nil) }
  scope :with_own_gpg_key, -> { where('gpg_key_private IS NOT NULL AND gpg_key_public IS NOT NULL') }
  scope :ordered, -> {
    ids = ::Distro.ids
    order(::Arel.sql("CASE #{ids.map { "WHEN distro_id = ? THEN ?" }.join(' ')} ELSE 10000 END", *ids.map.with_index.to_a.flatten))
  }

  def distro
    ::Distro[distro_id]
  end

  def distro=(dist)
    self.distro_id = dist.id
  end

  def storage_client
    if custom_storage?
      ::StorageClient.new(endpoint: endpoint, access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)
    else
      ::StorageClient.build_default
    end
  end

  def storage
    ::Repository::Storage.new(storage_client, bucket)
  end

  def gpg_key
    if with_own_gpg_key?
      ::Gpg::Key[gpg_key_private, gpg_key_public]
    else
      user.gpg_key
    end
  end

  def with_own_gpg_key?
    gpg_key_private.present? && gpg_key_public.present?
  end

  def installable_package_name
    project.installable_package_name(distro.id)
  end

  def installable_cli
    distro.install_steps.map do |command|
      format(command, project_safe_name: project.safe_name, installable_package_name: installable_package_name, url: storage.url)
    end.join("\n")
  end
end
