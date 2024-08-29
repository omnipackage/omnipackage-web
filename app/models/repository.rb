# frozen_string_literal: true

class Repository < ::ApplicationRecord
  belongs_to :project, class_name: '::Project', inverse_of: :repositories
  has_one :user, through: :project, class_name: '::User'

  validates :distro_id, inclusion: { in: ::Distro.ids }
  validates :gpg_key_private, :gpg_key_public, presence: true, allow_nil: true
  validates_with ::Repository::RepositoryValidator, unless: -> { ::Rails.env.test? }

  encrypts :gpg_key_private, :secret_access_key

  enum :publish_status, %w[pending publishing published].index_with(&:itself), default: 'pending'

  broadcast_with ::Broadcasts::Repository

  after_destroy_commit { ::DeleteFilesJob.perform_later(::StorageClient::Config.default, bucket, path_in_bucket) }

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

  def storage
    ::Repository::Storage.new(::StorageClient.new(project.storage_config), bucket, path_in_bucket)
  end

  def bucket
    project.storage_bucket
  end

  def path_in_bucket
    ::Pathname.new(project.storage_path).join(distro.slug).to_s
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
      format(command, project_slug: project.slug, installable_package_name: installable_package_name, url: storage.url)
    end.join("\n")
  end

  def humanized_name
    "#{project.name} / #{distro.name}"
  end
end
